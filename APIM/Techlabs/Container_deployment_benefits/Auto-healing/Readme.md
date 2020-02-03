## Auto-healing

Use following command in the shell:
```
k delete --force --grace-period=0 $(k get pods | grep api-manager- | cut -f 1 -d " ")
```

This will brutally stop the pod corresponding to API Manager. Since there should be 1, it will be automatically restarted. So we have this in Kubernetes Dashboard.
![pod_deleted.png](./imgs/pod_deleted.png)

After few seconds, it will be restarted.
![pod_recreated.png](./imgs/pod_deleted.png)

You can test to access API Manager using web browser shortcut.
![apimanager_login.png](./imgs/apimanager_login.png)

**Next:** [Elasticity](../Elasticity)
