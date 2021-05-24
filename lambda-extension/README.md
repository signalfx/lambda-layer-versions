# Splunk Extension for AWS Lambda

The Splunk Extension for AWS Lambda provides customers with a simplified runtime-independent
interface to collect high-resolution, low-latency metrics on AWS Lambda function execution. The
Splunk Extension layer tracks metrics for cold start, invocation count, function lifetime, and termination
condition. This enables customers to effectively monitor their AWS Lambda Functions with
minimal overhead.

## Concepts

The Splunk Extension for AWS Lambda sends metrics in real-time with minimal impact on a monitored function. Two ingest
modes help meet these requirements: 
* [fast ingest](#Fast-ingest) 
* [buffering](#Buffering)

You choose the ingest mode that best suits your case. 

Please refer to [the configuration section](#Configuration) for instructions on how to switch
between available modes.

### Fast ingest

This mode behaves in a way that is closest to the real-time monitoring, because it sends a metric
update every time a monitored function is invoked. This may have significant impact on the overall
duration of a function, and consequently fast ingest may result in poor user experience. The slowing
effect can be eliminated if Fast Invoke Response is enabled, but this may come at the cost of
increased concurrency and longer billed duration of the function.

Fast ingest mode is best suited for functions that:
* are rarely called
* can accept increased concurrency
* require real-time metrics

### Buffering

This mode sacrifices real-time characteristics so as to minimize impact on monitored
functions. Data points are buffered internally and sent at the interval you configure.
Unfortunately, buffering mode has a limitation rooted in the AWS extension architecture:
The last chunk of buffered data points can be sent with a significant delay, because AWS Lambda
may freeze the execution environment. This happens when each process in the execution environment
has completed and there are no pending events.

Buffering mode is best for users who do not need near real-time feedback and don't want to increase
function latency.

**_Note:_** In general, buffering mode should not be used for functions that are invoked less
frequently than the reporting interval, because such a combination may lead to data point delays greater
than the reporting interval.

### Tag/property synchronization

Metrics reported by the Splunk extension don't have tag/properties attached to them
out of the box. However, they support tag/properties synchronization. To enable this feature, you
have to configure an AWS data source in Splunk Observability Cloud that will pull in tag/properties
for AWS/Lambda namespace.

## Installation

You attach the Splunk extension for AWS Lambda to your Lambda function as a layer. This can be
done using: AWS CLI, AWS Console, AWS CloudFormation, etc. Please refer to the corresponding
documentation for the approach you use.

For example, if you wish to include Splunk extension in a container image:
1. Download the layer using aws cli:
    ```
    aws lambda get-layer-version-by-arn --region us-east-1 \
    --arn arn:aws:lambda:us-east-1:254067382080:layer:splunk-lambda-extension:1 \
    | jq -r '.Content.Location' | xargs curl -o extension.zip
    ```
   
2. Copy the layer inside your docker image and configure access token.
   For example, using the test application in [examples/app](examples/app):
    
    ```   
    FROM public.ecr.aws/lambda/nodejs:12
 
    # Add your application to the image (this adds sample app from examples/app)
    COPY examples/app/app.js examples/app/package.json /var/task/
 
    # Add the Splunk Extension you downloaded in a previous step
    COPY extension.zip extension.zip
    RUN yum install -y unzip && unzip extension.zip -d /opt && rm -f extension.zip
   
    # Set environment variables for the extension
    ENV SPLUNK_ACCESS_TOKEN <SPLUNK_ACCESS_TOKEN>
    # Set the realm if other than us0
    # ENV SPLUNK_REALM <SPLUNK_REALM>
 
    # Install NPM dependencies for function
    RUN npm install
 
    # Set the CMD to your handler
    CMD [ "app.handler" ] 
    ```
  
**_Note:_** If you want to attach the layer without downloading it (for example, in AWS Console), refer to the Layer ARN from the same region as your monitored function.
Check [the newest Splunk Extension for AWS Lambda versions](lambda-extension-versions.md)
for the adequate ARN.

It is important to tell the Extension Layer where to send data points. Use the environment variables of
your Lambda Function to configure the Extension Layer.
See [the configuration section](#Configuration) for all configuration options.

After you configure your AWS Lambda Extension Layer, you should see data points coming to your organization. Go
to [the dedicated dashboard](#Built-in-dashboard) to verify your setup. You can also build your own
dashboard based on [the metrics supported](#Metrics).

If you cannot see incoming data points, check [the troubleshooting instructions](#TROUBLESHOOTING).

## Built-in dashboard

You can build your own dashboard based on the metrics supported, but look first 
at [built-in dashboards](https://docs.signalfx.com/en/latest/getting-started/built-in-content/built-in-dashboards.html#built-in-dashboards). 
A dashboard dedicated to the Splunk Extension for AWS Lambda is available under
the `AWS Lambda` dashboard group. Its name is 'Lambda Extension'. The dashboard demonstrates what
can be achieved with [the metrics the Extension Layer supports](#Metrics), and could be a good
starting point for creating your own dashboard.

Some charts in the dashboard only populate if you
have [metadata synchronization](https://docs.signalfx.com/en/latest/integrations/amazon-web-services.html#importing-account-metadata-and-custom-tags)
for AWS Lambda namespace enabled. Otherwise, they will remain empty. This constraint applies, for example, to
the `Environment Details` chart.

## Metrics

The list of all metrics reported by Splunk Extension for AWS Lambda:

|Metric name|Type|Description|
|---|---|---|
|lambda.function.invocation|Counter|Number of Lambda Function calls.|
|lambda.function.initialization|Counter|Number of extension starts. This is the equivalent of the number of cold starts.|
|lambda.function.initialization.latency|Gauge|Time spent between a start of the extension and the first Lambda invocation (in milliseconds).|
|lambda.function.shutdown|Counter|Number of extension shutdowns.|
|lambda.function.lifetime|Gauge|Lifetime of one extension (in milliseconds). Extension lifetime may span multiple Lambda invocations.| 

**_Note:_** We currently do not support a metric that tracks execution time of a function. Please
consider using alternative indicators. The lifetime metric may help with functions that are rarely
called. Another indication of longer execution time may be increased function concurrency.

### Dimensions

The list of all dimensions associated with the metrics reported by the Splunk Extension for AWS Lambda:

|Dimension name|Description|
|---|---|
|AWSUniqueId|Unique ID used for correlation with the results of AWS/Lambda tag syncing.|
|aws_arn|ARN of the Lambda Function instance|
|aws_region|AWS Region|
|aws_account_id|AWS Account ID|
|aws_function_name|The name of the Lambda Function|
|aws_function_version|The version of the Lambda Function|
|aws_function_qualifier|AWS Function Version Qualifier (version or version alias, available only for invocations)|
|aws_function_runtime|AWS Lambda execution environment|
|aws_function_shutdown_cause|It is only present in the shutdown metric. It holds the reason of the shutdown.|

## Configuration

The Splunk Extension for AWS Lambda can be configured by environment variables of a Lambda Function.

Minimal configuration should include `SPLUNK_REALM` (or `SPLUNK_INGEST_URL`)
and `SPLUNK_ACCESS_TOKEN` variables, so the layer can identify the organization to which it should
send data points.

Below is the full list of supported environment variables:
 
|Name|Default value|Accepted values|Description|
|---|---|---|---|
|SPLUNK_REALM|`us0`| |The name of your organization's realm as described [here](https://dev.splunk.com/observability/docs/realms_in_endpoints/). It is used to build a standard endpoint for ingesting metrics.|
|SPLUNK_INGEST_URL| |`https://ingest.eu0.signalfx.com`|Real-time Data Ingest - you can find it in your account settings screen. It overrides the endpoint defined by the `SPLUNK_REALM` variable and it can be used to point to non standard endpoints.|
|SPLUNK_ACCESS_TOKEN| | |Access token as described [here](https://docs.signalfx.com/en/latest/admin-guide/tokens.html#access-tokens).|
|FAST_INGEST|`true`|`true` or `false`|Determines the strategy used to send data points. Use `true` to send metrics on every Lambda invocation ([fast ingest](#Fast-ingest) mode). With `false` metrics will be buffered and send out on intervals defined by `REPORTING_RATE` ([buffering](#Buffering) mode).|
|REPORTING_RATE|`15`|An integer (seconds). Minimum value is 1s.|Specifies how often data points are sent to Splunk. Due to the way the AWS Lambda execution environment works, metrics may be sent less often.|  
|REPORTING_TIMEOUT|`5`|An integer (seconds). Minimum value is 1s.|Specifies metric send operation timeout.|
|VERBOSE|`false`|`true` or `false`|Enables verbose logging. Logs are stored in a CloudWatch Logs group associated with a Lambda Function.|
|HTTP_TRACING|`false`|`true` or `false`|Enables detailed logs on HTTP calls to Splunk.|


## Troubleshooting

### I do not see data points coming

1. Check [Cloud Watch metrics](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html)
   of your Lambda Function. Make sure the Lambda Function is getting invoked. You can also check if
   errors are reported. Sometimes this indicates an issue with the Extension Layer. You can diagnose
   this by skipping to the 4th point.

2. Make sure `SPLUNK_REALM` (or `SPLUNK_INGEST_URL`) and `SPLUNK_ACCESS_TOKEN` variables are
   correctly configured. Refer to [the configuration section](#Configuration).

3. The Extension Layer working in the buffering mode may send data points with significant delay.
   Refer to [the fast ingest section](#Fast-ingest).

4. Enable verbose logging of the Extension Layer as described
   in [the configuration section](#Configuration).
   Check [Cloud Watch logs](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html)
   of your Lambda Function.   

