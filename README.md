# Helm Kubeval

A [GitHub Action](https://github.com/features/actions) for using [Kubeval](https://github.com/instrumenta/kubeval) to validate Helm Charts in your workflows.

Supports Helm 3 only.

## Example Workflow

You can use the action as follows:

```yaml
on: push
name: Validate
jobs:
  kubeval:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: test
      uses: desaintmartin/helm-kubeval-action@master
      with:
        path: ./helm-charts
        config: ./config_repos
```

By default the action will:

- Look for each Helm Chart
- For each, look for values file in its ci directory (otherwise don't use values file)
- run `helm template` and validate the output as Kubernetes objects.

## Inputs

The Helm Kubeval Action has a number of properties which map to the parameters for Kubeval itself. These are
passed to the action using `with`.


For more information on inputs, see the [API Documentation](https://developer.github.com/v3/repos/releases/#input)

| Property | Default | Description |
| --- | --- | --- |
| path | . | The path to the directory containing your Chart(s) |
| config | config_repos | The path to the configuration file containing your Chart(s) Repository Url(s) |
| output | stdout | How to format the output from Conftest (stdout, json or tap) |
| openshift | false | Whether or not to use the OpenShift schemas rather than the upstread Kubernetes ones |
| strict | true | Whether ot not to fail for additional properties in objects |
| ignore_missing_schemas | true | Whether to fail if unknown resources are found |
| version | master | Which version of Kubernetes to validate against |
