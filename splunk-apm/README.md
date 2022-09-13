# Splunk OpenTelemetry Lambda Layer

Splunk OpenTelemetry Lambda Layer for AWS Lambda enables seamless instrumentation of lambdas to collect metrics and traces. All components are preconfigured to use Splunk Observability Cloud as the back end. Users can enhance their existing Lambda functions by adding this Splunk-managed layer directly.

For x84_64 builds, use the layer name `splunk-apm` and update from [our published splunk-apm ARNs](./splunk-apm.md).

For arm64/graviton builds, use the layer name `splunk-apm-arm` and update from [our published splunk-apm-arm ARNs](./splunk-apm-arm.md).

## Get started 

The following components are currently supported:
- [Java wrapper](#java-wrapper) 
- [Python wrapper](#python-wrapper)
- [Node.js wrapper](#nodejs-wrapper)
- [Ruby wrapper](#ruby-wrapper)
- [Metrics extension](#metrics-extension)

### Configuration

All components are preconfigured to use Splunk Observability Cloud as the tracing backend.

1. Context propagation

    By default, W3C Trace Context and Baggage (`tracecontext,baggage`) propagators are used. 
    
    If you want to change this, set the `OTEL_PROPAGATORS` environment variable in your Lambda function code. 
   
2. Traces export

    By default:
    - Node.js wrapper uses the `Jaeger/Thrift` exporter
    - all other wrappers use the `OTLP/http/protobuf` exporter. 
    If the `SPLUNK_REALM` environment variable is set, the value of the`OTEL_EXPORTER_OTLP_ENDPOINT` environment variable is `https://ingest.${SPLUNK_REALM}.signalfx.com/v2/trace/otlp`, the direct ingest URL for Splunk Observability Cloud. 
    To make it work, you need to set following variables:
     ```
     SPLUNK_ACCESS_TOKEN: <org_access_token>
     SPLUNK_REALM: <splunk_realm>
     ``` 
    If you want to change the endpoint, set this environment variable in your Lambda function code:
    ```
    OTEL_EXPORTER_OTLP_ENDPOINT: <endpoint URL>
    ```
    In the case of Jaeger Thrift exporter modified by Splunk (`jaeger-thrift-splunk`), the endpoint (`OTEL_EXPORTER_JAEGER_ENDPOINT`) will be set to `https://ingest.${SPLUNK_REALM}.signalfx.com/v2/trace`, the direct ingest URL for Splunk Observability Cloud if `SPLUNK_REALM` property is set as well. 
    If you want to change the endpoint, set this environment variable in your Lambda function code:
    ```
    SPLUNK_ACCESS_TOKEN: <org_access_token>
    OTEL_EXPORTER_JAEGER_ENDPOINT: <endpoint URL>
    ```

3. OpenTelemetry Metrics export

    By default, OpenTelemetry metrics are disabled.    
    
4. Sampling

    `OTEL_TRACE_SAMPLER` is set to `always_on` by default, meaning that all spans are always sampled.

5. Span flush

    Spans are sent synchronously, before the lambda function terminates. Default span flush wait timeout is 30 seconds. It is controlled with a following environment variable (value in milliseconds):
    ```
    OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT: 30000
    ```

6. Logging

    Logging is controller with `OTEL_LOG_LEVEL` environment variable. When set to `DEBUG`, additional data will be logged to help with troubleshooting. 
    Please note that enabling `DEBUG` will generate additional logs which may in turn increase AWS CloudWatch costs. 
    
7. Server-Timing header (Splunk RUM integration).
    
    The RUM integration is enabled by default, which means that every HTTP response from an instrumented lambda will contain following headers:
    ```
    Access-Control-Expose-Headers: Server-Timing
    Server-Timing: traceparent;desc="00-<trace-id>-<span-id>-<trace-flags>"
    ```

8. Splunk Metrics export

   By default, Splunk metrics are enabled with Splunk Metrics extension. Following configuration environment variables are required:
   ```
   SPLUNK_REALM: <Splunk Realm>
   SPLUNK_ACCESS_TOKEN: <Access token>
   ```      

### Java wrapper

The Java wrapper is based on OpenTelemetry Java version 1.10.0. 

The official documentation of the upstream layer can be found [here](https://github.com/open-telemetry/opentelemetry-lambda/blob/main/java/README.md).

1. Installation

    No code change is needed to instrument a lambda. However, the `AWS_LAMBDA_EXEC_WRAPPER` environment variable must be set accordingly: 
    - `/opt/otel-handler` for wrapping regular handlers implementing `RequestHandler`
    - `/opt/otel-proxy-handler` for wrapping regular handlers implementing `RequestHandler`, proxied through API Gateway, and enabling HTTP context propagation
    - `/opt/otel-stream-handler` for wrapping streaming handlers implementing `RequestStreamHandler`

2. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://github.com/open-telemetry/opentelemetry-java/tree/v1.1.0/sdk-extensions/autoconfigure#customizing-the-opentelemetry-sdk) for the OpenTelemetry Java.    

### Python wrapper

The Python wrapper is based on Splunk Distribution of OpenTelemetry Python version `v1.4.0`. 

The official documentation of the upstream layer can be found [here](https://github.com/open-telemetry/opentelemetry-lambda/blob/main/python/README.md).

1. Installation

    Set the `AWS_LAMBDA_EXEC_WRAPPER` environment variable to `/opt/otel-instrument`.
 
2. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://github.com/signalfx/splunk-otel-python/blob/main/docs/advanced-config.md#trace-propagation-configuration) for the Splunk distribution of OpenTelemetry Python.
    
3. Serverless framework support

    The Serverless Framework (https://www.serverless.com/) offers features that can impact OpenTelemetry tracing for you Python lambda. Review following documented cases:
    
    * Requirements ZIP
    
      The feature (https://github.com/serverless/serverless-python-requirements#dealing-with-lambdas-size-limitations) allows packing and deploying lambda dependencies as a separate ZIP file. In order to allow instrumentation of such packages, set `SPLUNK_LAMBDA_SLS_ZIP` environment variable to `true` (default is `false`).
        
    * Slim package
    
      The feature (https://github.com/serverless/serverless-python-requirements#slim-package) downsizes lambda package by removing some files, including `dist-info` folders. These meta files are required by the OpenTelemetry Python autoinstrumentation. Therefore either the `slim` option needs to be disabled or the custom pattern (`slimPatternsAppendDefaults: false`) option needs to be enabled. Consult `serverless` documentation for additional details. 

### Node.js wrapper

The Node.js wrapper is based on Splunk Distribution of OpenTelemetry for Node.js version `0.15.0`. 

The documentation of the base distribution can be found [here](https://github.com/signalfx/splunk-otel-js).

1. Installation

    Set the `AWS_LAMBDA_EXEC_WRAPPER` environment variable to `/opt/nodejs-otel-handler`.
 
2. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://github.com/signalfx/splunk-otel-js/blob/main/docs/advanced-config.md#advanced-configuration) for the Splunk distribution of OpenTelemetry for Node.js.

### Ruby wrapper

The Ruby wrapper is based on OpenTelemetry SDK for Ruby version `1.0.2` and OpenTelemetry Instrumentation for Ruby version `0.23.0`.

The documentation of the base distribution can be found [here](https://github.com/open-telemetry/opentelemetry-ruby).

1. Installation

    Set the `AWS_LAMBDA_EXEC_WRAPPER` environment variable to `/opt/ruby-otel-handler`.
    
2. Context propagation

    For more information about available context propagators, see the [Propagator settings](https://opentelemetry.io/docs/instrumentation/ruby/context_propagation/).


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
```

#### Node.js

The example assumes the following:

- Data is sent to Splunk APM directly via Ingest endpoint.
- Context propagation is default (`tracecontext,baggage`).
- Realm is `us0`.

Following environment variables should be set:
```
AWS_LAMBDA_EXEC_WRAPPER: /opt/nodejs-otel-handler
SPLUNK_ACCESS_TOKEN: <org_access_token>
SPLUNK_REALM: us0
```

#### Ruby

The example assumes the following:

- Data is sent to Splunk APM directly via Ingest endpoint.
- Context propagation is default (`tracecontext,baggage`).
- Realm is `us0`.

Following environment variables should be set:
```
AWS_LAMBDA_EXEC_WRAPPER: /opt/ruby-otel-handler
SPLUNK_ACCESS_TOKEN: <org_access_token>
SPLUNK_REALM: us0
```

### Metrics extension

The Splunk Extension for AWS Lambda provides customers with a simplified runtime-independent interface to collect high-resolution, low-latency metrics on AWS Lambda function execution. The Splunk Extension layer tracks metrics for cold start, invocation count, function lifetime, and termination condition. This enables customers to effectively monitor their AWS Lambda Functions with minimal overhead.

Full documentation with examples can be found [here](https://github.com/signalfx/splunk-extension-wrapper/tree/main/docs).

## Troubleshooting

1. If traces are not showing in APM 
    - Set `OTEL_LOG_LEVEL` to `DEBUG` and check the CloudWatch logs.
    - Increase `OTEL_INSTRUMENTATION_AWS_LAMBDA_FLUSH_TIMEOUT` if the backend / network responds slowly.
2. If metrics are not showing in APM
    - Set `VERBOSE` to `true` and check the CloudWatch logs.   

## License and versioning

The project is released under the terms of the Apache Software License version 2.0.
