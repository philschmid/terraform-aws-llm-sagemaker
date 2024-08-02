package test

import (
	"context"
	"encoding/json"
	"log"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sagemakerruntime"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Run example
// AWS_PROFILE=hf-sm AWS_DEFAULT_REGION=us-east-1 go test -v

// Helper function to create Terraform options
func createTerraformOptions() *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"endpoint_name_prefix": "llama3",
			"hf_model_id":          "meta-llama/Meta-Llama-3-8B-Instruct",
			"instance_type":        "ml.g5.2xlarge",
			"tgi_config": map[string]interface{}{
				"max_input_tokens":       4000,
				"max_total_tokens":       4096,
				"max_batch_total_tokens": 6144,
			},
		},
	}
}

// Helper function to send a request to the SageMaker endpoint using AWS SDK
func invokeSageMakerEndpoint(endpointName string, body map[string]interface{}) (map[string]interface{}, error) {
	// Load the AWS configuration using environment variables
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	// Create a SageMaker Runtime client
	sageMakerClient := sagemakerruntime.NewFromConfig(cfg)

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	input := &sagemakerruntime.InvokeEndpointInput{
		EndpointName: aws.String(endpointName),
		ContentType:  aws.String("application/json"),
		Body:         jsonBody,
	}

	result, err := sageMakerClient.InvokeEndpoint(context.TODO(), input)
	if err != nil {
		return nil, err
	}

	var response map[string]interface{}
	if err := json.Unmarshal(result.Body, &response); err != nil {
		return nil, err
	}

	return response, nil
}

func TestSageMakerPlan(t *testing.T) {
	t.Parallel()

	terraformOptions := createTerraformOptions()

	planStdout := terraform.InitAndPlan(t, terraformOptions)
	expectedContainer := "763104351884.dkr.ecr.us-east-1.amazonaws.com/huggingface-pytorch-tgi-inference:2.3.0-gpu-py310-cu121-ubuntu22.04"

	assert.Contains(t, planStdout, expectedContainer, "Container image should be present in the plan")

}

func TestSageMakerEndpointDeployment(t *testing.T) {
	t.Parallel()

	terraformOptions := createTerraformOptions()
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	endpointName := terraform.Output(t, terraformOptions, "sagemaker_endpoint_name")

	// Define the request body
	requestBody := map[string]interface{}{
		"messages": []map[string]string{
			{"role": "system", "content": "You are a helpful assistant."},
			{"role": "user", "content": "What is deep learning?"},
		},
	}

	// Send request to the SageMaker endpoint
	response, err := invokeSageMakerEndpoint(endpointName, requestBody)
	log.Printf("Response: %v", response)
	assert.NoError(t, err)
	assert.NotNil(t, response)

}
