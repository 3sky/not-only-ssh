define deploy
  $(eval $@_REGION = "eu-central-1")
  $(eval $@_STACK_NAME = $(1))
	cfn-lint $($@_STACK_NAME).yaml
	aws cloudformation deploy --stack-name $($@_STACK_NAME) \
	--template-file $($@_STACK_NAME).yaml \
	--region $($@_REGION) \
	--capabilities CAPABILITY_NAMED_IAM
	aws cloudformation wait stack-create-complete --stack-name $($@_STACK_NAME)
	aws cloudformation describe-stacks --stack-name $($@_STACK_NAME) --query "Stacks[].Outputs" --no-cli-pager
endef

define destroy
  $(eval $@_REGION = "eu-central-1")
  $(eval $@_STACK_NAME = $(1))
	aws cloudformation delete-stack --stack-name $($@_STACK_NAME) --region $($@_REGION)
endef

clean-1:
	@$(call destroy,"example-1")

clean-2:
	@$(call destroy,"example-2")

clean-3:
	@$(call destroy,"example-3")

clean-4:
	@$(call destroy,"example-4")

example-1:
	@$(call deploy,"example-1")

example-2:
	@$(call deploy,"example-2")

example-3:
	@$(call deploy,"example-3")

example-4:
	@$(call deploy,"example-4")

generate-ssh-config:
	aws cloudformation describe-stacks --stack-name example-2 --query "Stacks[].Outputs" --no-cli-pager | jq -r '.[][] | if .OutputKey == "THSInstance" then "Host \(.OutputKey)\n  ProxyJump THSBastion\n  PreferredAuthentications publickey\n  IdentitiesOnly=yes\n  IdentityFile /Users/kuba/.ssh/id_ed2219_ths\n  User ec2-user\n  Hostname \(.OutputValue)\n  Port 22\n\n" else "Host \(.OutputKey)\n  PreferredAuthentications publickey\n  IdentitiesOnly=yes\n  IdentityFile /Users/kuba/.ssh/id_ed2219_ths\n  User ec2-user\n  Hostname \(.OutputValue)\n  Port 22\n\n" end' > ~/.ssh/config.d/ths

