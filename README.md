# Splunk APM lambda layers

## Overview

Before you deploy a Splunk APM lambda layer to your AWS account, review the available versions and regions for supported languages.
Additionally, based on your deployment method in AWS, you will need to copy the ARN information. 


## List of Splunk APM lambda layers

| Description                | Documentation                                                                      | Link to Supported Layer ARNs 
| -------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------
| OpenTelemetry Java Wrapper | [Main README](https://github.com/signalfx/splunk-otel-java-lambda)                 | [List of supported layer versions](./otel-java/OTEL-JAVA.md)     
| SignalFx Java Wrapper      | [Main README](https://github.com/signalfx/lambda-java)                             | [List of supported layer versions](./java/JAVA.md)     
| SignalFx Node Wrapper      | [Main README](https://github.com/signalfx/lambda-nodejs)                           | [List of supported layer versions](./node/NODE.md)        
| SignalFx Python Wrapper    | [Main README](https://github.com/signalfx/lambda-python)                           | [List of supported layer versions](./python/PYTHON.md)        
| SignalFx Ruby Wrapper      | [Main README](https://github.com/signalfx/lambda-ruby)                             | [List of supported layer versions](./ruby/RUBY.md)        
| SignalFx C# Wrapper        | [Main README](https://github.com/signalfx/lambda-csharp)                           | [List of supported layer versions](./csharp/CSHARP.md)        
| SignalFx Metrics Extension | [Main README](https://github.com/signalfx/splunk-extension-wrapper/tree/main/docs) | [List of supported layer versions](./lambda-extension/lambda-extension-versions.md)
| Splunk APM                 | [Main README](./splunk-apm/README.md)                                              | [List of supported layer versions](./splunk-apm/splunk-apm.md) 


## Installation methods

At a high-level, there are three ways to add the Splunk wrapper / extension. 

   * Option 1: In AWS, create a Lambda function, then attach a Splunk-hosted layer with a wrapper.
      * If you are already using Lambda layers, then Splunk recommends that you follow this option. 
      * In this option, you will use a Lambda layer created and hosted by Splunk.
      * To learn more about this method, see [Splunk Python Lambda Wrapper](https://github.com/signalfx/lambda-python/blob/master/README.rst). 
   * Option 2 (**only applicable for wrappers**): In AWS, create a Lambda function, then create and attach a layer based on a Splunk SAM (Serverless Application Model) template.
      * If you are already using Lambda layers, then Splunk recommends that you follow this option. 
      * In this option, you will choose a Splunk template, and then deploy a copy of the layer.
      * To learn more about this method: 
          1. Open your AWS console. 
          2. In the top menu, click **Services**. 
          3. Enter and select **Browse serverless app repository**. 
          4. Click the **Readme** tab, and review the installation documentation. 
   * Option 3 (**only applicable for wrappers**): Use the wrapper as a regular dependency, and then create a Lambda function based on your artifact containing both code and dependencies.   
      * To learn more about this method, see [Splunk Python Lambda Wrapper](https://github.com/signalfx/lambda-python/blob/master/README.rst). 