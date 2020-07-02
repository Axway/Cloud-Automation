## 5. Create Cloud2Cloud flow

- In Integration Builder, select the Flows tab and click **"Build New Flow"**
- A list is displayed, click **"Build New Flow"**
- Type the following flow name **"Salesforce to Slack exercise"** and click **"Create"**
![Create_flow1.png](./imgs/Create_flow1.png)

- Click **"Add Event"** on Event panel
- Type **${config.source}** on the field **"connector instance variable"**.
- Click **"Save"**. A flow diagram is displayed with “trigger” selection


![Create_flow2.png](./imgs/Create_flow2.png)

- Click on **"Manage"**, then on **"Manage variables"**.
- Define three variables like the following table.
- Finally click on **"Save"** to validate the creation.


![Create_flow3.png](./imgs/Create_flow3.png)

- Click **"+"** below the «trigger» step
- Click **"ADD STEP"** and select **"Connector API Request"**
- Complete the following fields and click **"Save"**:
    - Name: **getSalesforceLeadInfo**
    - Connector Instance Variable: select the source variable : **${config.source}**
    - Method: Select **"GET"** from the drop-down list
    - API: **/leads/${trigger.event.objectId}**


![Create_flow4.png](./imgs/Create_flow4.png)

- Click on **"getSalesforceLeadInfo"** step, and select **"ADD ONSUCCESS"**
- Click on **ADD STEP** button 
- Select on **"JS Script"**
- Type the following name **createSlackMessageBody**
- Put the following JSON code, and click **"Save"**:

*const l = steps.getSalesforceLeadInfo.response.body;*

*const s = "Salesforce";*

*const nom = l.FirstName + " " + l.LastName;*

*const message = {*

*"text" : "A new lead, " + "'" + nom + "'" + " has arrived in " + s + "!"*

*};*

*done(message);*


![Create_flow5.png](./imgs/Create_flow5.png)

- Click on **"createSlackMessageBody"** step, and select **"ADD ONSUCCESS"**
- Click on **ADD STEP** button 
- Select on **"Connector API Request"**
- Type the following values and click **"Save"**:
    - Name: **sendSlackMessage**
    - Connector Instance Variable: select the messaging variable **${config.messaging}**
    - Method: Select **"POST"** from the drop-down list
    - API: **/channels/${config.channel}/messages**
    - Under Show Advanced, Body: **${steps.createSlackMessageBody}**

![Create_flow6.png](./imgs/Create_flow6.png)

The completed flow diagram should look like the following image :


![Create_flow7.png](./imgs/Create_flow7.png)

**Next:** [Now let's create an instance of our flow](../6.Instantiate_Cloud2Cloud_flow)

