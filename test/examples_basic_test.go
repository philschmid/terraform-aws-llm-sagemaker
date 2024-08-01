package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	// "github.com/aws/aws-sdk-go/aws"
	// "github.com/aws/aws-sdk-go/aws/session"
	// "github.com/aws/aws-sdk-go/service/sagemaker"
)

func TestSageMakerEndpoint(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
	}

	// destroys resources after the test completes, regardless of whether the test passes or fails.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`
	terraform.InitAndApply(t, terraformOptions)

	// Get the endpoint name from Terraform output
	endpointName := terraform.Output(t, terraformOptions, "bucket_name")

	// assert it is not empty
	assert.Empty(t, endpointName, "Endpoint name should not be empty")
}

// package test

// import (
// 	"github.com/aws/aws-sdk-go/aws"
// 	"github.com/aws/aws-sdk-go/aws/session"
// 	"github.com/aws/aws-sdk-go/service/sagemaker"
// 	"github.com/gruntwork-io/terratest/modules/terraform"
// 	"github.com/stretchr/testify/assert"
// 	"testing"
// )

// func TestSageMakerEndpoint(t *testing.T) {
// 	terraformOptions := &terraform.Options{
// 		TerraformDir: "../examples/basic",
// 	}

// 	// destroys resources after the test completes, regardless of whether the test passes or fails.
// 	defer terraform.Destroy(t, terraformOptions)

// 	// Run `terraform init` and `terraform apply`
// 	terraform.InitAndApply(t, terraformOptions)

// 	// Get the endpoint name from Terraform output
// 	endpointName := terraform.Output(t, terraformOptions, "endpoint_name")

// 	// Create AWS session
// 	sess, err := session.NewSession(&aws.Config{
// 		Region: aws.String("us-west-2"), // Replace with your AWS region
// 	})
// 	if err != nil {
// 		t.Fatal(err)
// 	}

// 	// Create SageMaker client
// 	sagemakerClient := sagemaker.New(sess)

// 	// Describe the endpoint to check if it exists and is in service
// 	describeEndpointInput := &sagemaker.DescribeEndpointInput{
// 		EndpointName: aws.String(endpointName),
// 	}
// 	describeEndpointOutput, err := sagemakerClient.DescribeEndpoint(describeEndpointInput)
// 	if err != nil {
// 		t.Fatal(err)
// 	}

// 	// Assert that the endpoint status is "InService"
// 	assert.Equal(t, "InService", *describeEndpointOutput.EndpointStatus, "Endpoint should be in service")
// }
