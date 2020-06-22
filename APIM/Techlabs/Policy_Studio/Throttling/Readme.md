## Throttling

At the end of this section, you will have a throttling policy limiting one single request every 5 seconds per consumer.
This is our target:
![throttling_expected_result](./imgs/throttling_expected_result.png)

When you test:
- if quota is respected, response is **"Access to service authorized"**. 
- if quota rights are exceeded, response is **"Access to service denied"**.

### Implementation of the **"Quota System"** policy

In the tree view on the left of the screen,
- Expand **"Policies"**
- If **TechLabs** container doesn't exist, right click on **"Policies"** and click **"Add Container"**
![add_techlabs_container](./imgs/add_techlabs_container.png)

- Write "TechLabs" then click OK
![add_techlabs_container_validation](./imgs/add_techlabs_container_validation.png)

- Right-click on the **"TechLabs"** container and select **"Add Policy"**

![add_policy](./imgs/add_policy.png)

In the window which appears,
- For the **"Name"** field, enter **"Quota System"**
- Click **"OK"**.

![add_policy_panel](./imgs/add_policy_panel.png)

Core of this quota limitation, is detecting if limit of use per unit of time is reached. This is the purpose of  **"Throttling"** filter.
To get it quickly, let use the search zone, located at the top of the right-hand column, and enter **"thro"**
The **"Throttling"** filter appears in the **"Content Filtering"** section 
- Drag and drop this filter to the main frame

![throttling_filter_dad](./imgs/throttling_filter_dad.png)

The default configuration for this filter authorizes processing one message every second. 
We will configure the filter to accept the processing of one message every 5 seconds.
- Replace the value 1 in the **"every"** zone with the value **"5"** 

![throttling_panel](./imgs/throttling_panel.png)
 
- Click **"Finish"**.

- Let's define this step as the first of our policy. Right-click on the **"Throttling"** filter and select **"Set as Start"**.

![set_as_start](./imgs/set_as_start.png)


You should have the following:

![throttling_step](./imgs/throttling_step.png)
 

Now that the **"Throttling"** filter is in place, we will set the result of the request based on the current quota. 
To do this, we will use the **"Set Message"** and **"Reflect Message"** filters.
- The **"Set Message"** filter is used to initialize the format and the content of a message.
- The **"Reflect Message"** filter is used to return the message of the request. 

We will now set the content of the message in the eventuality that the quota is not reached
- Start entering **"Set Message"** in the search zone at the top-right hand corner.
- Select the **"Set Message"** filter 
- Drag and drop this filter to the **"Throttling"** filter.
![set_message_1_dad](./imgs/set_message_1_dad.png)

In the **"Configure a new 'Set Message' filter"** window,
- For the **"Name"** field, enter **"Set Message OK"**
- For the **"Content-Type"** field, enter **"text/html"**
- For the **"Message Body"** field, enter
```
<html>
<body>
Access to service authorized
</body>
</html>
```
- Click on the **"Finish"** button

![set_message_1_panel](./imgs/set_message_1_panel.png)

- Create a success path between Throttling and Set Message filtes.
Select **Success Path** into Filers panel then, in the Policy, click on **Throttling** first and next on **Set message OK**.
![add_success_path](./imgs/add_success_path.png)

- Start entering **"Reflect Message"** in the search zone in the top-right.
Select the **"Reflect Message"** filter.
- Drag and drop this filter to the **"Set Message OK"** filter.

![reflect_1_dad](./imgs/reflect_1_dad.png)
 
In the **"Configure a new 'Reflect Message' filter"** window, 
- For the **"Name"** field, add **"Reflect Message 200"**
- For the **"HTTP response code status"** field, enter **"200"**
- Click on the **"Finish"** button

![reflect_1_panel](./imgs/reflect_1_panel.png)

- Select **Success Path** filter to link **"Set Message OK"** to **"Reflect Message 200"**.

We will now put in place the processing of an error message informing that the quota has been reached.
- Start entering **"Set Message"** in the search zone in the top-right.
- Select the **"Set Message"** filter 
- Drag and drop this filter on top of the **"Throttling"** filter.
As the **"Throttling"** filter already has a success path (green arrow), adding another filter will create a failure path (a red arrow).

![set_message_2_dad](./imgs/set_message_2_dad.png)

In the **"Configure a new 'Set Message' filter"** window,
- For the **"Name"** field, enter **"Set Message KO"**
- For the **"Content-Type"** field, enter **"text/html"**
- For the **"Message Body"** field, enter 
```
<html>
<body>
Access to service denied
</body>
</html>
```
- Click on the **"Finish"** button

![set_message_2_panel](./imgs/set_message_2_panel.png)

- Create a failure path between Throttling and Set Message KO filtes.
Select **Failure Path** into Filers panel then, in the Policy, click on **Throttling** first and next on **Set message KO**.
![add_failure_path](./imgs/add_failure_path.png)


- Start entering **"Reflect Message"** in the search zone in the top-right.
Select the **"Reflect Message"** filter.

![reflect_2_dad](./imgs/reflect_2_dad.png)

Drag and drop this filter on top of the **"Set Message KO"** filter.


- In the **"Configure a new 'Reflect Message' filter"** window, 
- In the **"Name"** field, enter **"Reflect Message 500"**
- In the **"HTTP response code status"** field, enter **"500"** 
- Click on the **"Finish"** button

![reflect_2_panel](./imgs/reflect_2_panel.png)

- Select **Success Path** filter to link **"Set Message KO"** to **"Reflect Message 500"**.

The **"Set Response Status"** filter is used to explicitly add a message in the Monitoring displays. 
If this policy proceeds correctly, it will by default be considered positive (whether or not the quota is reached).
However, if the quota is reached, the result of the policy must be an error situation in order to be highlighted in the Monitoring displays (logical and non-technical error). 
We will therefore use the **"Set Response Status"** filter, to raise this error result, when the **"Throttling"** filter detects that the quota has been reached.
- Start entering the policy name **"Set Response Status"** in the search zone in the top-right.
- Select the **"Set Response Status"** filter 
- Drag and drop this filter on top of the **"Reflect Message 500"** filter.

![set_response_status_dad](./imgs/set_response_status_dad.png)


- In the **"Configure a new 'Set Response Status' filter"** window, 
- For the **"Name"** field, enter **"Set Response Status fail"**
- For the **"Response Status"** field, select the **"Fail"** radio button
- Click on the **"Finish"** button
 
![set_response_status_panel](./imgs/set_response_status_panel.png)


You obtain the following result:
![throttling_policy_done](./imgs/throttling_policy_done.png)


###	Defining the listener

Our first policy is done. Now is the time to test it. Let's make it callable by HTTP. 

It can be done by a shortcut to the default HTTP listener (called "Default Services").
Click the **"Add relative path"** icon at bottom of the screen: 
- For the **"When a request arrives that matches the path"** field, enter **"/TechLabs/quota"**
- Then click OK

![relative_path_shortcut.png](./imgs/relative_path_shortcut.png)

**"Note:"** the created relative path can be seen in the **"Default Services"** listener. Path resolver are managed from this menu. 
**"Environment:"** Do not worry if you do not have the same paths listed. For our scenario only **"/TechLabs/quota"** matters.

![default_services_throttling.png](./imgs/default_services_throttling.png)


###	Deployment

Policy configuration requires deployment to server to be active  
To do this, you have two possibilities:
- Press **"F6"**.
or
- Click on the deployment icon at the top-right hand corner of the **"Axway Policy Studio"** window
![deployment_shortcut.png](./imgs/deployment_shortcut.png)

The window **"Deploy"** appears. You connect to the system by identifying yourself:
**"Environment:"** please use the right deployment host and port
- Enter **"changeme"** in the field ****"Password"****
- Click **"Next"**

![deployment_panel.png](./imgs/deployment_panel.png)


- In the field **"Group"**, select the only group defined
- Click **"Next"**

![deployment_panel_2.png](./imgs/deployment_panel_2.png)

**"Environment:"** Do not worry if you have multiple instances, keep them all.

- Once the configuration has been deployed, click **"Finish"**

![deployment_panel_2.png](./imgs/deployment_panel_3.png)


### Tests
- To proceed with the tests, use a web browser. 
- In the browser, enter the URL: **[Default Service url]**/TechLabs/quota
For example, if **[Default Service url]** is http://localhost:8080, use http://localhost:8080/TechLabs/quota

![test_throttling_1.png](./imgs/test_throttling_1.png)

- Click several times on the refresh button to simulate successive requests. 

![test_throttling_2.png](./imgs/test_throttling_2.png)


**Expected result**: On the first request, the service returns a positive response. The request submitted has been accepted by the **"Throttling"** filter.
If the number of requests is less than one every 5 seconds, the responses returned will be **"Access to service authorized"** (Access to service authorized).
If the number of requests is greater than one every 5 seconds, the responses will be negative: **"Access to service denied"** (Access to service denied).

![test_throttling_3.png](./imgs/test_throttling_3.png)


###	The API Gateway Manager
The API Gateway Manager is the web console for the administration of the Axway solution. It includes monitoring capabilitieswe will use right now.
- In the browser, please use **API Gateway Manager** shortcut : 
 
![anm_browser.png](./imgs/anm_browser.png)

- If authentication is asked, 
Enter **"admin"** in the field **"Username"** 
Enter **"changeme"** in the field **"Password 
 
![anm_login.png](./imgs/anm_login.png)


#### Dashboard
The **"Dashboard"** tab displays:
- The statistics for traffic on the platform.
- The deployment topology for nodes, instances and their associated states.
- The top 5 most-used services on the server.
The **"Dashboard"** tab displays the total number of messages processed by the API Gateway platform. 
**Environment**: healthcheck is regularly called in a kubernetes environment. This affects traffic count. Transactions are hidden in Traffic Monitor for readability.
You calls to **"Quota System"** ar ealso included policy:

![anm_dashboard](./imgs/anm_dashboard.png)

The positive responses are listed in **"Messages passed"** and the negative ones indicated in **"Messages Failed"**.

#### Monitoring
The **"Monitoring"** tab offers:
- A real-time view of the statistics of the API Gateway server activity.
- These statistics are grouped into categories: System / API Services / API Methods/ Clients / Remote Hosts.

![anm_monitoring.png](./imgs/anm_monitoring.png)

#### Traffic
The **"Traffic"** tab is an interface dedicated to developers and administrators in order to view the details of a specific request. 
In the **"Traffic"** tab, it is possible to identify the requests which have been accepted (Status: 200 OK) and those which have been rejected (Status: 500 Internal Server Error)

![anm_traffic.png](./imgs/anm_traffic.png)

**Next:** [Let's add authentication mechanism](../Authentication_based_quota_policy)
