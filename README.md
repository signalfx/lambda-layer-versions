<h2>Overview</h2>

Before you deploy a SignalFx lambda wrapper layer to your AWS account, review the available versions and regions for supported languages.

Additionally, based on your deployment method in AWS, you will need to copy the ARN information. 

---

<h2>Latest available versions of SignalFx Lambda wrapper layers:</h2>

| Supported Languages      | Link to Supported Layer Versions |
| ----------- | ----------- |
| Java      | [Click for list of supported layer versions](./java/JAVA.md)     |
| Node   | [Click for list of supported layer versions](./node/NODEJS.md)        |
| Python   | [Click for list of supported layer versions](./python/PYTHON.md)        |
| Ruby   | [Click for list of supported layer versions](./ruby/RUBY.md)        |
| C#   | [Click for list of supported layer versions](./csharp/CSHARP.md)        |

---

<h2>Installation methods</h2>

At a high-level, there are three ways to add the SignalFx wrapper. 

   * Option 1: Use the wrapper as a regular dependency, and then create a Lambda function based on your artifact containing both code and dependencies.
      * To learn more about this method, see [SignalFx Python Lambda Wrapper](https://github.com/signalfx/lambda-python/blob/master/README.rst). 
   * Option 2: In AWS, create a Lambda function, then attach a SignalFx-hosted layer with a wrapper.
      * To learn more about this method, see [SignalFx Python Lambda Wrapper](https://github.com/signalfx/lambda-python/blob/master/README.rst). 
   * Option 3: In AWS, create a Lambda function, then create and attach a layer based on a SignalFx SAM (Serverless Application Model) template.
      * To learn more about this method:
          1. Open your AWS console. 
          2. In the top menu, click **Services**. 
          3. Enter and select **Browse serverless app repository**. 
          4. Click the **Readme** tab, and review the installation documenation. 
   

---

<h2> Troubleshooting / request support</h2>

SignalFx does not provide Go layers. To request support for Go layers or to host a layer in another region, please open an issue in the [repository](https://github.com/signalfx/lambda-layer-versions).


<!--
For maintainers: commits to this repo are made automatically when a build and integration testing in signalfx-lambda-layers repo pass.-->
