BUCKET_NAME="tf-state-1234509876"  # generate a random number or leave as it is, let's just make sure it's globally unique
REGION="us-east-1"

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --object-ownership BucketOwnerEnforced

aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'
