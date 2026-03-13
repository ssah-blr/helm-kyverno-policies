# Kyverno Policies Helm Chart

## Purpose
This Helm chart deploys Kyverno policies to a Kubernetes cluster.
These policies help enforce best practices for container security and resource management.

---

## Prerequisites
- Kubernetes cluster (v1.21+) with Kyverno installed
- Helm v3.x installed on your system
- kubectl configured to access your cluster

---

## Installing the Chart

Add the chart repository (optional if you host your own chart repo):

```bash
$ helm repo add my-charts <CHART_REPO_URL>
$ helm repo update

Install the chart into your desired namespace (e.g., kyverno-policies):

```bash
$ helm install kyverno-policies ./helm \
--namespace kyverno-policies \
--create-namespace

### Uninstalling the Chart

```bash
$ helm uninstall kyverno-policies --namespace kyverno-policies

This will remove all policies deployed by the chart.

Testing Policies Locally

```bash
$ chmod +x test.sh
$ ./test.sh

This will validate all policies in the chart against the sample test resources in the templates/*/tests directories.
