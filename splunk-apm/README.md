# Splunk distribution of OpenTelemetry Lambda

Splunk OTeL lambda is a downstream distribution of opentelemetry-lambda. Supported OpenTelemetry Lambda layers are preconfigured to use Splunk as the tracing backend (direct ingest or SmartAgent). Users can enhance their existing Lambda functions by adding Splunk-managed layer directly. Layer ARNs [are published here](https://github.com/signalfx/lambda-layer-versions/).

## Get started 

Currently, following components are supported:
- [Java wrapper](#java-wrapper) 

### Configuration

All wrapper layers are preconfigured to use Splunk as the tracing backend.

1. Context propagation
    By default, W3C Trace Context and Baggage (`tracecontext,baggage`) propagators are used. 
    
    If you want to change this, set the `OTEL_PROPAGATORS` environment variable in your Lambda function code. For more information about available context propagators, see the [Propagator settings](https://github.com/open-telemetry/opentelemetry-java/tree/v1.1.0/sdk-extensions/autoconfigure#customizing-the-opentelemetry-sdk) for the OpenTelemetry Java.

2. Traces export
    By default, the OpenTelemetry Protocol (`otlp`) exporter is used.
    If you want to use this exporter, set these environment variables in your Lambda function code:
    ```
    OTEL_EXPORTER_OTLP_ENDPOINT: <Endpoint URL>
    ```
    Splunk provides also a token-authenticated `jaeger-thrift-splunk` exporter for customers that need to use that specific protocol. To use it, set the following environment variables:
    ```
    OTEL_TRACES_EXPORTER: jaeger-thrift-splunk
    OTEL_EXPORTER_JAEGER_ENDPOINT: <Endpoint URL>
    SPLUNK_ACCESS_TOKEN: orgAccessToken
    ``` 
    By default, `OTEL_EXPORTER_JAEGER_ENDPOINT` is set to `http://127.0.0.1:9080/v1/trace` (local SmartAgent endpoint)
   
    Default span flush wait timeout is 1 second. It is controlled with a following environment variable (value in milliseconds):
    ```
    OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT: 30000
    ```
3. OpenTelemetry Metrics export

    By default, OTEL metrics are disabled.    
    
4. Sampling

    `OTEL_TRACE_SAMPLER` is set to `always_on` by default, meaning that all spans are always sampled.

5. Logging
    
    Logging is controller with `OTEL_LAMBDA_LOG_LEVEL` environment variable. Default set to `WARN`. When set to `DEBUG`, the logging exporter is added to traces exporter in order to help verify exported data.
    
    > Enabling `DEBUG` generates additional logs, which may in turn increase AWS CloudWatch costs. 

### Java wrapper

The Java wrapper is based on OpenTelemetry Java version 1.5.0. 

The official documentation of the upstream layer can be found [here](https://github.com/open-telemetry/opentelemetry-lambda/blob/main/java/README.md).

No code change is needed to instrument a lambda. However, the `AWS_LAMBDA_EXEC_WRAPPER` environment variable must be set accordingly: 
- `/opt/otel-handler` for wrapping regular handlers implementing `RequestHandler`
- `/opt/otel-proxy-handler` for wrapping regular handlers implementing `RequestHandler`, proxied through API Gateway, and enabling HTTP context propagation
- `/opt/otel-stream-handler` for wrapping streaming handlers implementing `RequestStreamHandler`

#### Configuration example

The example assumes the following:

- Data is sent to Splunk APM directly via Ingest endpoint.
- Context propagation is default (`tracecontext,baggage`).
- It's a RequestHandler lambda.
- Realm is `us0`.

Following environment variables should be set:
```
AWS_LAMBDA_EXEC_WRAPPER: /opt/otel-handler
OTEL_TRACES_EXPORTER: jaeger-thrift-splunk
SPLUNK_ACCESS_TOKEN: <token>
OTEL_EXPORTER_JAEGER_ENDPOINT: https://ingest.us0.signalfx.com/v2/trace
```

## Troubleshooting

1. If traces are not delivered 
    - Set `OTEL_LAMBDA_LOG_LEVEL` to `DEBUG` and search for traces IDs in the backend.
    - Set `OTEL_LAMBDA_LOG_LEVEL` to `DEBUG` for the `jaeger-thrift-splunk' exporter. This shows debug information for the exporter.
    - Increase `OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT`if the backend / network reacts slowly.

## License and versioning

The project is released under the terms of the Apache Software License version 2.0.
