'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s): Victoria Lassner
'''

import boto3
import random
import string
import json

# You are only required to load up to 100 incidents to avoid unnecessary bills from the cloud computing provider.
TOTAL_INCIDENTS = 100
DYNAMODB_REGION = 'us-west-1'

# Table names
KEYS_TABLE_NAME = 'AuthenticationKeys'
INCIDENTS_TABLE_NAME = 'Incidents'

def generate_hex_key():
    return ''.join(random.choices(string.hexdigits.lower(), k=32))

def main():
    # Initialize DynamoDB resource
    dynamodb = boto3.resource('dynamodb', region_name=DYNAMODB_REGION)

    # Reference tables
    keys_table = dynamodb.Table(KEYS_TABLE_NAME)
    incidents_table = dynamodb.Table(INCIDENTS_TABLE_NAME)

    # === Generate and save keys ===
    keys = [generate_hex_key() for _ in range(3)]
    
    for key in keys:
        keys_table.put_item(Item={'key_id': key})

    # Save keys to keys.txt
    with open('keys.txt', 'w') as f:
        for key in keys:
            f.write(f'{key}\n')
    print("Generated keys saved to keys.txt")

    # === Load incidents ===
    try:
        with open('data/incidents.json', 'r') as f:
            all_incidents = json.load(f)
    except FileNotFoundError:
        print("File data/incidents.json not found.")
        return

    # Limit to TOTAL_INCIDENTS
    incidents = all_incidents[:TOTAL_INCIDENTS]

    # Upload incidents
    for incident in incidents:
        if 'uid' not in incident:
            # Generate a unique ID if not present
            incident['uid'] = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
        try:
            incidents_table.put_item(Item=incident)
        except Exception as e:
            print(f"Error inserting incident: {e}")

    print(f"Successfully loaded {len(incidents)} incidents into the DynamoDB table.")

if __name__ == "__main__":
    main()