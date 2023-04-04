status=$(kubectl get pipelinerun/$PIPELINE_NAME -n rh-openshift-pipelines-instance -o=jsonpath='{.status.conditions[*].status}');
reason=$(kubectl get pipelinerun/$PIPELINE_NAME -n rh-openshift-pipelines-instance -o=jsonpath='{.status.conditions[*].reason}');
if ([ $status == "True" ] && [ $reason == "Succeeded" ]);
then
    echo 'Exiting 0'
    exit 0
else
    echo 'Exiting 1'
    exit 1
fi