[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/03yGW8O6)
# Overview

In this project, you are tasked with implementing a web service for sharing cybersecurity incidents. The implementation must use the serverless computing paradigm, with the required infrastructure built on AWS using Terraform technology.

# Instructions

The project is divided into two parts, which are explained in the following sections.

## Part 1

Complete the embedded to-do's in the Terraform script located in [part1](part1). This script creates two DynamoDB tables: one for storing authentication keys and another for saving incidents. Save the keys in a file named **keys.txt** for easy testing later. 

Once the tables are created, complete the data load portion of this assignment using the [src/init_db.py](src/init_db.py) script. The dataset for this project was originally obtained from the [Cyber Events Database Home](https://cissm.umd.edu/research-impact/publications/cyber-events-database-home). It has been exported to JSON format and is available at [data/incidents.json](data/incidents.json).

## Part 2

Finish the implementation of the Lambda function in [src/prj_02_lambda.py](src/prj_02_lambda.py). The function should accept at least three query parameters, in addition to the required authentication key. Document the chosen query parameters below:

```

year -> filter by year they occured
actor   -> filter based on who caused them
country -> filter by affected countries

```

The Lambda function should return the following JSON files, depending on the conditions described. 

**Success**

```
{
    'statusCode': 200,
    'body': { 
        'items': response['Items']
    }
}
```

**Authentication Failed**

```
{
    'statusCode': 401,
    'body': { 
        'message': 'Authentication failed'
    }
}
```

**Internal Server Error**

```
{
    'statusCode': 500,
    'body': { 
        'message': 'Internal server error', 
        'error': <description of the error>
    }
}
```

Once you are done with the Lambda function implementation, proceed to packaging it. You need to write your own Dockerfile. 

Finish the Terraform code in [part2](part2) that creates an API gateway with a single (root) endpoint served by the Lambda function built previously. 

## Testing & Grading

Use the ```api_gateway_url``` endpoint to test the API, making sure that the API is authenticating the keys created in the DynamoDB table. Inform the ```api_gateway_url``` below. 

```
api_gateway_url: "https://ejy7zpvc05.execute-api.us-west-1.amazonaws.com/prod"
```

To get full credit on this assignment, you need to push the following files with your changes: README.md, part1/*.tf, part2/*.tf, src/init_db.py, src/prj_02_lambda.py, DockerFile, and keys.txt. 

After you receive your grade, make sure to destroy your cloud computing infrastructure created in both parts 1 and 2. 

# Rubric 

```
+10 part 1 (terraform)
+20 src/init_db 
+5 keys.txt
+10 Dockerfile 
+35 src/prj_02_lambda 
-5 deduction for each of the three required query parameters 
-10 deduction if key authentication is not working
+20 part 2 (terraform)
```



docker build -t lambda-image .
docker tag lambda-image:latest 060795946302.dkr.ecr.us-west-1.amazonaws.com/lambda-repo:latest
docker push 060795946302.dkr.ecr.us-west-1.amazonaws.com/lambda-repo:latest
