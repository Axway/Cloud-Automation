## Elasticity

Elasticity is the capability of a system to provision and de-provision resources automatically.

In next chapter we will see auto-scaling, and the capability to add more resources. So let's prove here elasticy the other way: reducing the number of resources.

Let's go to Kubernetes Dashboard and select api-traffic deployment.
![dashboard_deployment_list.png](./imgs/dashboard_deployment_list.png)

Let's look at api-traffic configuration. There is currently 3 replicas on 3 expected. Another way to say it is we have 3 API Gateway instances working.
![apitraffic_replicas.png](./imgs/apitraffic_replicas.png)

Let's scroll down to **"Horizontal Pods Autoscalers"**. As name stands, this is the configuration for auto-scaling. 
![horizontal_scaler.png](./imgs/horizontal_scaler.png)

We can see minimum is 3. It is meant for high availability. For our demonstration, we need to allow 1 minimum.
- Expand the right menu and select **"View/edit YAML"**
![horizontal_scaler_edit.png](./imgs/horizontal_scaler_edit.png)
- Set **"minReplicas"** to 1
- Click **"UPDATE"**
![edit_yaml.png](./imgs/edit_yaml.png)

If you take a look, nothing changes for the replicas. 
![apitraffic_replica_minimum_updated.png](./imgs/apitraffic_replica_minimum_updated.png)

Because 3 is still between 1 and 6. If we had try to scale down to 1 witthout this change, autoscaler would have put back to 3 replicas.


Once down, changing replicas is really straightforward:
- Click on **"Scale"**
- Change from **"3"** replicas to **"1"** replica
- Click **"OK"**  
![apitraffic_scale.png](./imgs/apitraffic_scale.png)

Immediatly target replica changed.
![replica_set.png](./imgs/replica_set.png)

Just a little later, 2 pods stopped and we reached target.
![target_replica.png](./imgs/target_replica.png)

The same way, we could have scaled up. But let's the autoscaler do it for us!

**Next:** [Auto-scaling](../Auto-scaling)