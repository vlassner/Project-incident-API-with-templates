FROM public.ecr.aws/lambda/python:3.11

RUN yum update -y && yum install -y zip

RUN mkdir /build
RUN mkdir /build/lib

RUN pip install boto3 --target=/build/lib

COPY src/prj_02_lambda.py /build

WORKDIR /build 

RUN zip -r9 ../prj_02_lambda.zip .