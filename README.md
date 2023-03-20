# Splunk layers for AWS Lambda

Before you deploy a Splunk lambda layer to your AWS account, review the available versions and regions for supported languages.
Additionally, based on your deployment method in AWS, you might need to copy the ARN information. 

For install instructions, see the [official documentation](https://quickdraw.splunk.com/redirect/?product=Observability&location=learnmore.aws.lambda.layer&version=current).

## List of Splunk layers for AWS Lambda

| Description                       | Documentation                                                                      | Link to Supported Layer ARNs 
| --------------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------
| **Splunk OpenTelemetry Lambda Layer** | [Official docs](https://quickdraw.splunk.com/redirect/?product=Observability&location=learnmore.aws.lambda.layer&version=current)                                              | [List of supported layer versions](./splunk-apm/splunk-arns.md) 
| OpenTelemetry Java Wrapper        | [README](https://github.com/signalfx/splunk-otel-java-lambda)                 | [List of supported layer versions](./otel-java/OTEL-JAVA.md)            
| SignalFx C# Wrapper               | [README](https://github.com/signalfx/lambda-csharp)                           | [List of supported layer versions](./csharp/CSHARP.md)        
| SignalFx Metrics Extension        | [README](https://github.com/signalfx/splunk-extension-wrapper/tree/main/docs) | [List of supported layer versions](./lambda-extension/lambda-extension-versions.md)

>ℹ️&nbsp;&nbsp;SignalFx was acquired by Splunk in October 2019. See [Splunk SignalFx](https://www.splunk.com/en_us/investor-relations/acquisitions/signalfx.html) for more information.
