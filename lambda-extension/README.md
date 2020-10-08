# Overview

The SignalFx Lambda Extension Layer provides customers with a simplified runtime-independent interface to collect high-resolution, low-latency metrics on Lambda Function execution.
The Extension Layer tracks metrics for cold start, invocation count, function lifetime and termination condition enabling customers to efficiently and effectively monitor their Lambda Functions with minimal overhead.

# Installation

Refer to the [Lambda Extension versions](lambda-extension-versions.md) to find the layer ARN for your AWS region.

To attach the SignalFx Lambda Extension Layer to your Lambda Function, complete the steps below:

1. Add the layer to your Lambda Function. There are a few ways to do this:
    * while [creaing new Lambda Function](https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html)
    * while [updating an existing Lambda Function configuration](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html#configuration-layers-using)
    * or using [AWS CLI](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/index.html#cli-aws-lambda) 

2. Configure the layer using environment variables. You can find the list of all supported variables in [the configuration section below](#Configuration).

   Make sure you have configured both INGEST and TOKEN variables correctly.

3. After you invoke your Lambda Function you should see data points coming to SignalFx.
You can check that on [the builtin dashboard](https://docs.signalfx.com/en/latest/getting-started/built-in-content/built-in-dashboards.html) dedicated for the SignalFx Lambda Extension Layer.
It is available under the AWS Lambda dashboard group.

4. If you do not see any data points refer to [the troubleshooting instructions](#TROUBLESHOOTING).


## Metrics

The list of all metrics reported by the SignalFx Lambda Extension Layer:

|Metric name|Type|Description|
|---|---|---|
|lambda.function.invocation|Counter|Number of Lambda Function calls.|
|lambda.function.initialization|Counter|Number of extension starts. This is the equivalent of the number of cold starts.|
|lambda.function.initialization.latency|Gauge|Time spent between the Lambda Function execution and its first invocation (in milliseconds).|
|lambda.function.shutdown|Counter|Number of extension shutdowns.|
|lambda.function.lifetime|Gauge|Lifetime of one extension (in milliseconds).| 

## Reported Dimensions

The list of all dimensions associated with the metrics reported by the SignalFx Lambda Extension Layer:

|Dimension name|Description|
|---|---|
|AWSUniqueId|Unique ID used for correlation with the results of AWS/Lambda tag syncing.|
|aws_arn|ARN of the Lambda Function instance|
|aws_region|AWS Region|
|aws_account_id|AWS Account ID|
|aws_function_name|The name of the Lambda Function|
|aws_function_version|The version of the Lambda Function|
|aws_function_qualifier|AWS Function Version Qualifier (version or version alias, available only for invocations)|
|aws_function_runtime|AWS execution environment|
|cause|It is only present in the shutdown metric. It holds the reason of the shutdown.|

## Configuration

The SignalFx Lambda Extension Layer can be configured by environment variables of a Lambda Function.

The list of all supported environment variables:
 
|Name|Default value|Accepted values|Description|
|---|---|---|---|
|INGEST|`https://ingest.signalfx.com/v2/datapoint`|`https://ingest.{REALM}.signalfx.com/v2/datapoint`|A metrics ingest endpoint as described [here](https://developers.signalfx.com/ingest_data_reference.html#tag/Send-Metrics).|
|TOKEN| | |An access token as described [here](https://docs.signalfx.com/en/latest/admin-guide/tokens.html#access-tokens).|
|REPORTING_RATE|`15`|An integer (seconds). Minimum value is 1s.|Specifies how often data points are sent to SignalFx. Due to the way the AWS Lambda execution environment works metrics may be sent less often.|  
|REPORTING_TIMEOUT|`5`|An integer (seconds). Minimum value is 1s.|Specifies metric send operation timeout.|
|VERBOSE|`false`|`true` or `false`|Enables verbose logging. Logs are stored in a CloudWatch Logs group associated with a Lambda function.|
|HTTP_TRACING|`false`|`true` or `false`|Enables detailed logs on HTTP calls to SignalFx.|


## Troubleshooting

1. Check metrics of your Lambda Function as described [here](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html).
Make sure the Lambda Function:
    * is getting invoked
    * does not report errors

2. Check logs of your Lambda Function as described [here](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html). You can also consider enabling verbose mode as described in [the configuration section](#Configuration).