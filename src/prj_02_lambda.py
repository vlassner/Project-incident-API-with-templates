'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s): Victoria Lassner
'''

import json
import boto3
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource('dynamodb')
keys_table = dynamodb.Table('AuthenticationKeys')
incidents_table = dynamodb.Table('Incidents')

def lambda_handler(event, context):
    try:
        print(f"Received event: {json.dumps(event)}")  # Log the event received by the Lambda function
        
        # Extract API key from query parameters
        auth_key = event.get('queryStringParameters', {}).get('key', '')
        print(f"Auth key received: {auth_key}")
        
        valid_key = keys_table.get_item(Key={'key_id': auth_key})

        if 'Item' not in valid_key:
            return {
                'statusCode': 401,
                'body': json.dumps({'message': 'Authentication failed'})
            }
        
        # Extract query parameters for filtering
        year = event.get('queryStringParameters', {}).get('year')
        actor = event.get('queryStringParameters', {}).get('actor')
        country = event.get('queryStringParameters', {}).get('country')
        
        print(f"Filters: Year={year}, Actor={actor}, Country={country}")

        # Build the filter expression based on the query parameters
        filter_expression = None

        if year:
            filter_expression = Attr('year').eq(year)
        if actor:
            filter_expression = filter_expression & Attr('actor').eq(actor) if filter_expression else Attr('actor').eq(actor)
        if country:
            filter_expression = filter_expression & Attr('country').eq(country) if filter_expression else Attr('country').eq(country)

        # Query the incidents table
        response = incidents_table.scan(
            FilterExpression=filter_expression if filter_expression else None,
            Limit=100
        )

        # Log the response before returning
        print(f"Scan result: {json.dumps(response.get('Items', []))}")

        return {
            'statusCode': 200,
            'body': json.dumps({'items': response.get('Items', [])})
        }

    except Exception as e:
        print(f"Error: {str(e)}")  # Log the error message
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal server error', 'error': str(e)})
        }