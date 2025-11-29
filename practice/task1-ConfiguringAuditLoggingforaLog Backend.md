Namespace: kube-system, default

Documentation: Auditing, kube-apiserver, ConfigMap

Use this interactive lab to practice the following skills for the Certified Kubernetes Security Specialist (CKS) exam:

Inspecting an existing audit policy file
Enhancing an existing audit policy file
Configuring audit logging
Identifying a logged event
Each step of the lab must be completed correctly before you can move to the next step. If you get stuck, you can view the solution and learn how to complete the step.

t1:
Edit the existing audit policy file at /etc/kubernetes/audit/rules/audit-policy.yaml. Add a rule that logs events for ConfigMaps and Secrets at the Metadata level. Add another rule that logs events for Services at the Request level.
Solution:
Edit the existing audit policy file at /etc/kubernetes/audit/rules/audit-policy.yaml. The existing content looks as follows:

apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
- "RequestReceived"
  rules:
- level: RequestResponse
  resources:
    - group: ""
      resources: ["pods"]
      Add the rules asked about in the instructions. The content of the final audit policy file could look as follows:

apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
- "RequestReceived"
  rules:
- level: RequestResponse
  resources:
    - group: ""
      resources: ["pods"]
- level: Metadata
  resources:
    - group: ""
      resources: ["secrets", "configmaps"]
- level: Request
  resources:
    - group: ""
      resources: ["services"]
      The audit policy file has not yet been configured with the API server. You will need to do so in the next step.
  
t2:
Configure the API server to consume the audit policy file. Logs should be written to the file /var/log/kubernetes/audit/logs/apiserver.log. Define a maximum number of 5 days to retain audit log files.
solution:

Configure the API server to consume the audit policy file by editing the file /etc/kubernetes/manifests/kube-apiserver.yaml. Provide additional options, as requested. The relevant configuration needed is shown here:

...
spec:
containers:
- command:
    - kube-apiserver
    - --audit-policy-file=/etc/kubernetes/audit/rules/audit-policy.yaml
    - --audit-log-path=/var/log/kubernetes/audit/logs/apiserver.log
    - --audit-log-maxage=5
      ...
      volumeMounts:
    - mountPath: /etc/kubernetes/audit/rules/audit-policy.yaml
      name: audit
      readOnly: true
    - mountPath: /var/log/kubernetes/audit/logs/
      name: audit-log
      readOnly: false
      ...
      volumes:
- name: audit
  hostPath:
  path: /etc/kubernetes/audit/rules/audit-policy.yaml
  type: File
- name: audit-log
  hostPath:
  path: /var/log/kubernetes/audit/logs/
  type: DirectoryOrCreate

The Pod running the API server should automatically restart. This process may take a couple of minutes. Once fully restarted, you should be able to query for it.

$ kubectl get pods -n kube-system
NAME                          READY   STATUS    RESTARTS   AGE
...
kube-apiserver-controlplane   1/1     Running   0          69s
HINT: If the command responds with a connection error, then the API server Pod is in the process of being restarted or you introduced a configuration issue. Check the API server log files under /var/log/pods if the Pod no longer comes up after a reasonable amount of time.

