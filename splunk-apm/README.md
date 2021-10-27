# Splunk OpenTelemetry Lambda Layer

Splunk OpenTelemetry Lambda Layer for AWS lambda enables seamless instrumentation of lambdas to collect metrics and traces. All components are preconfigured to use Splunk Observability Cloud as the backend, either through direct ingest or via the Smart Agent). Users can enhance their existing Lambda functions by adding the Splunk-managed layer directly. Layer ARNs [are published here](./splunk-apm.md).

## Get started 

Currently, following components are supported:
- [Java wrapper](#java-wrapper)
- [Python wrapper](#python-wrapper)  
- [Metrics extension](#metrics-extension)

### Configuration

All components are preconfigured to use Splunk as the tracing backend.

1. Context propagation

    By default, W3C Trace Context and Baggage (`tracecontext,baggage`) propagators are used. 
    
    If you want to change this, set the `OTEL_PROPAGATORS` environment variable in your Lambda function code. 
   
2. Traces export

    By default, all wrappers use the OTLP/gRPC exporter. 
    The endpoint (`OTEL_EXPORTER_OTLP_ENDPOINT`) will be set to `https://ingest.${SPLUNK_REALM}.signalfx.com/v2/trace/otlp`, the direct ingest URL for Splunk Observability Cloud if `SPLUNK_REALM` property is set as well. 
    To make it work, you need to set following variables:
     ```
     SPLUNK_ACCESS_TOKEN: <org_access_token>
     SPLUNK_REALM: <splunk_realm>
     ``` 
    If you want to change the endpoint, set this environment variable in your Lambda function code:
    ```
    OTEL_EXPORTER_OTLP_ENDPOINT: <endpoint URL>
    ```
    
    Wrappers also support Jaeger/Thrift exporter modified by Splunk (`jaeger-thrift-splunk`). 
    The endpoint (`OTEL_EXPORTER_JAEGER_ENDPOINT`) will be set to `https://ingest.${SPLUNK_REALM}.signalfx.com/v2/trace`, the direct ingest URL for Splunk Observability Cloud if `SPLUNK_REALM` property is set as well. 
    If you want to change the endpoint, set this environment variable in your Lambda function code:
    ```
    SPLUNK_ACCESS_TOKEN: <org_access_token>
    OTEL_EXPORTER_JAEGER_ENDPOINT: <endpoint URL>
    ```
   
   > **_NOTE:_**  Currently Splunk Observability Cloud supports only OTLP `http/protobuf` protocol. In order to send traces directly to ingest, set `OTEL_EXPORTER_OTLP_TRACES_PROTOCOL: http/protobuf` environment variable in your Lambda function code.

3. OpenTelemetry Metrics export

    By default, OpenTelemetry metrics are disabled.    
    
4. Sampling

    `OTEL_TRACE_SAMPLER` is set to `always_on` by default, meaning that all spans are always sampled.

5. Splunk Metrics export

   By default, Splunk metrics are enabled with Splunk Metrics extension. Following configuration environment variables are required:
   ```
   SPLUNK_REALM: <Splunk Realm>
   SPLUNK_ACCESS_TOKEN: <Access token>
   ```      
 
### Java wrapper

The Java wrapper is based on OpenTelemetry Java version 1.6.0. 

The official documentation of the upstream layer can be found [here](https://github.com/open-telemetry/opentelemetry-lambda/blob/main/java/README.md).

1. Installation

    No code change is needed to instrument a lambda. However, the `AWS_LAMBDA_EXEC_WRAPPER` environment variable must be set accordingly: 
    - `/opt/otel-handler` for wrapping regular handlers implementing `RequestHandler`
    - `/opt/otel-proxy-handler` for wrapping regular handlers implementing `RequestHandler`, proxied through API Gateway, and enabling HTTP context propagation
    - `/opt/otel-stream-handler` for wrapping streaming handlers implementing `RequestStreamHandler`

2. Span flush

    Spans are sent synchronously, before the lamda function terminates. Default span flush wait timeout is 1 second. It is controlled with a following environment variable (value in milliseconds):
    ```
    OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT: 30000
    ```
   
3. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://github.com/open-telemetry/opentelemetry-java/tree/v1.1.0/sdk-extensions/autoconfigure#customizing-the-opentelemetry-sdk) for the OpenTelemetry Java.

4. Logging
    
    Logging is controller with `OTEL_LAMBDA_LOG_LEVEL` environment variable. Default set to `WARN`. When set to `DEBUG`, the logging exporter is added to traces exporter in order to help verify exported data.
    
    Please note that enabling `DEBUG` will generate additional logs which may in turn increase AWS CloudWatch costs. 

### Python wrapper

The Python wrapper is based on Splunk Distribution of OpenTelemetry Python version `v1.0.0`. 

The official documentation of the upstream layer can be found [here](https://github.com/open-telemetry/opentelemetry-lambda/blob/main/python/README.md).

1. Installation

    Set the `AWS_LAMBDA_EXEC_WRAPPER` environment variable to `/opt/otel-instrument`.
 
2. Span flush

    Spans are sent synchronously, before the lamda function terminates. Flush timeout is set to maximum 30 seconds. 
    
3. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://github.com/signalfx/splunk-otel-python/blob/main/docs/advanced-config.md#trace-propagation-configuration) for the Splunk distribution of OpenTelemetry Python.

### Metrics extension

The Splunk Extension for AWS Lambda provides customers with a simplified runtime-independent interface to collect high-resolution, low-latency metrics on AWS Lambda function execution. The Splunk Extension layer tracks metrics for cold start, invocation count, function lifetime, and termination condition. This enables customers to effectively monitor their AWS Lambda Functions with minimal overhead.

Full documentation with examples can be found [here](https://github.com/signalfx/splunk-extension-wrapper/tree/main/docs).



### Configuration example

#### Java
The example assumes the following:

- Data is sent to Splunk APM directly via Ingest endpoint.
- Context propagation is default (`tracecontext,baggage`).
- It's a RequestHandler lambda.
- Realm is `us0`.

Following environment variables should be set:
```
AWS_LAMBDA_EXEC_WRAPPER: /opt/otel-handler
SPLUNK_ACCESS_TOKEN: <org_access_token>
SPLUNK_REALM: us0
OTEL_EXPORTER_OTLP_TRACES_PROTOCOL: http/protobuf
```

#### Python

The example assumes the following:

- Data is sent to Splunk APM directly via Ingest endpoint.
- Context propagation is default (`tracecontext,baggage`).
- Realm is `us0`.

Following environment variables should be set:
```
AWS_LAMBDA_EXEC_WRAPPER: /opt/otel-instrument
SPLUNK_ACCESS_TOKEN: <org_access_token>
SPLUNK_REALM: us0
OTEL_EXPORTER_OTLP_TRACES_PROTOCOL: http/protobuf
```

## Troubleshooting

1. If traces are not delivered 
    - Set `OTEL_LOG_LEVEL` to `DEBUG` and check the CloudWatch logs.
    - Set `OTEL_LAMBDA_LOG_LEVEL` to `DEBUG` and search for traces IDs in the backend.
    - Set `OTEL_LAMBDA_LOG_LEVEL` to `DEBUG` for the `jaeger-thrift-splunk' exporter. This shows debug information for the exporter.
    - Increase `OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT`if the backend / network reacts slowly.

## License and versioning

The project is released under the terms of the Apache Software License version 2.0.
