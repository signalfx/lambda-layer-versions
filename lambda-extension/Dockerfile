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
