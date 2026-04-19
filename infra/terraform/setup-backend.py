#!/usr/bin/env python3
"""
Script to create Terraform backend S3 bucket and DynamoDB table for state locking
Run this before terraform init
"""

import boto3
import sys
from botocore.exceptions import ClientError

def create_backend_infrastructure():
    s3 = boto3.client('s3')
    dynamodb = boto3.client('dynamodb')
    
    bucket_name = 'hexideate-terraform-state'
    table_name = 'terraform-locks'
    region = 'us-east-1'
    
    # Create S3 bucket
    try:
        s3.create_bucket(Bucket=bucket_name)
        print(f"✓ Created S3 bucket: {bucket_name}")
    except ClientError as e:
        if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
            print(f"✓ S3 bucket already exists: {bucket_name}")
        else:
            print(f"✗ Error creating S3 bucket: {e}")
            sys.exit(1)
    
    # Enable versioning
    try:
        s3.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={'Status': 'Enabled'}
        )
        print(f"✓ Enabled versioning on bucket: {bucket_name}")
    except ClientError as e:
        print(f"✗ Error enabling versioning: {e}")
    
    # Enable encryption
    try:
        s3.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [
                    {
                        'ApplyServerSideEncryptionByDefault': {
                            'SSEAlgorithm': 'AES256'
                        }
                    }
                ]
            }
        )
        print(f"✓ Enabled encryption on bucket: {bucket_name}")
    except ClientError as e:
        print(f"✗ Error enabling encryption: {e}")
    
    # Block public access
    try:
        s3.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print(f"✓ Blocked public access to bucket: {bucket_name}")
    except ClientError as e:
        print(f"✗ Error blocking public access: {e}")
    
    # Create DynamoDB table for state locking
    try:
        dynamodb.create_table(
            TableName=table_name,
            KeySchema=[
                {'AttributeName': 'LockID', 'KeyType': 'HASH'}
            ],
            AttributeDefinitions=[
                {'AttributeName': 'LockID', 'AttributeType': 'S'}
            ],
            BillingMode='PAY_PER_REQUEST'
        )
        print(f"✓ Created DynamoDB table: {table_name}")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceInUseException':
            print(f"✓ DynamoDB table already exists: {table_name}")
        else:
            print(f"✗ Error creating DynamoDB table: {e}")
            sys.exit(1)
    
    print("\n✓ Backend infrastructure ready!")
    print(f"Bucket: {bucket_name}")
    print(f"Table: {table_name}")

if __name__ == '__main__':
    create_backend_infrastructure()
