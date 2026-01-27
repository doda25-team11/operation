### Week Q1.1 (Nov 10+)
No work
### Week Q1.2 (Nov 17+)

- Radu: https://github.com/doda25-team11/app/pull/3 & https://github.com/doda25-team11/model-service/pull/4, reviewed https://github.com/doda25-team11/model-service/pull/5

I have worked on A1's F8. Added a packaging, versioning and releasing workflow to both the app and model-service repositories, that parses the version from the app repo's pom.xml and releases the container images of both to the GitHub registry.

- Rodrigo: https://github.com/doda25-team11/model-service/pull/5 & https://github.com/doda25-team11/model-service/pull/3

I have worked on A1's F9 and F10. Add a workflow to train the ML model, and removed the hard coded model from the dockerfile.

- Arnas: https://github.com/doda25-team11/lib-version

I worked on versioning and deployment of the lib-version. All commits there are mine this week. I worked on F1, F2 and F11.

- Figen: https://github.com/doda25-team11/operation/pull/1

I have worked on A1's F7, writing the docker-compose file to onfiguring services, environment variables, networking, volume mapping.

- Amy: https://github.com/doda25-team11/model-service/pull/2 & https://github.com/doda25-team11/model-service/pull/6

I worked on F4 and F6, making sure multiple architectures are supported and being able to set the ports (both frontend and backend) manually.

- Bill: https://github.com/doda25-team11/app/pull/1 & https://github.com/doda25-team11/model-service/pull/1

I worked on F3 and F5. Running the frontend and backend outside the containers, then I analysed the working of the backend with POSTMAN. Then I containerise the frontend and the backend (backend with multi-stage). 

I code reviewed: https://github.com/doda25-team11/model-service/pull/2 & https://github.com/doda25-team11/model-service/pull/3 & https://github.com/doda25-team11/app/pull/2

NOTE: I helped Amy with F6 and tested the code with her.

### Week Q1.3 (Nov 24+)

- Arnas:

This week, not much was happening on my part.

- Bill: https://github.com/doda25-team11/operation/pull/4 & https://github.com/doda25-team11/operation/pull/5 & https://github.com/doda25-team11/operation/pull/2

I implemented steps 9 till 12 with the two PRs and tested this.

I code reviewed: https://github.com/doda25-team11/operation/pull/2

NOTE: I helped Amy with her step 15 because that didn't work. She couldn't figure it out so I implemented the fixes in her PR.

- Amy: https://github.com/doda25-team11/operation/pull/7
I worked on step 13-17. There were some troubles with copying the admin file to the host, so I got some help with that. I reviewed/tested steps 4-8. 

- Rodrigo: https://github.com/doda25-team11/operation/pull/3
I worked on steps 4-8 and reviewed steps 1-3. I also worked on fixing F10 because it still used 'latest' (although this PR was merged in Week 4)

- Figen: https://github.com/doda25-team11/operation/pull/2
Created VMs for bothworker and control and using ansible

- Radu

Didn't make any PRs, spent most of the time trying to get the in-class exercises and setup for A2 to work

### Week Q1.4 (Dec 1+)
- Bill: https://github.com/doda25-team11/operation/pull/9
I implemented steps 16 and 17 of assignment 2 still.

I code reviewed: https://github.com/doda25-team11/operation/pull/7

- Radu: https://github.com/doda25-team11/operation/pull/11

I have assigned myself to complete the last steps of A2 (20-23), and only got to work on them in W4 because the repo was not yet in a state where we were confident there were no task dependencies affecting steps 20-23

- Rodrigo: https://github.com/doda25-team11/operation/pull/8 + PR mentioned in the previous week
I implemented the helm chart and part of the migration. I code reviewed PRs related to Steps 16-17 and 20-21

- Amy
I didn't create any new PR's. I finalized step 13-17 (see week 3) and spent time on making the In-class exercises work on my own laptop.

- Figen
I did not make any PR's. I spent my time on making the in-class exercises and started with A3, but have not made much progress yet.

- Arnas https://github.com/doda25-team11/operation/pull/10
I have worked on steps 18 and 19 of A2. I have assigned myself step 3 of A3. I also fixed some bugs. I have helped wih 16 and 17 of A2.

### Week Q1.5 (Dec 8+)
- Bill: https://github.com/doda25-team11/operation/pull/13 
I helped Figen with checking and fixing the worker nodes not joining the cluster and we decided together that the fix is to use another IP. There were
other fixes possible like pinging the worker node but I decided to not implement this solution and we decided to go with Figen's commit in the PR.

- Radu: https://github.com/doda25-team11/operation/pull/11, https://github.com/doda25-team11/operation/pull/12

Still working on testing and merging A2's steps 20-21, made PR for A2's steps 22-23 and starting to work on A3

- Rodrigo: https://github.com/doda25-team11/operation/pull/11
Worked on the traffic management + canary release of A4. Reviewed and collaborated on steps 20-23 of A2 since it needed fixing.

- Arnas: https://github.com/doda25-team11/app/pull/4

I made the monitoring metrics for A3 Prometheus. I used Figen's code for inspiration (https://github.com/doda25-team11/app/commits/A3.3-Metrics/). I explained the metrics in README in operation.

- Figen:
I worked on fixing the problems we had with A2 for the people using Oracle Virtualbox: https://github.com/doda25-team11/operation/pull/13
I added prometheus as a dependency: https://github.com/doda25-team11/operation/pull/14
I created the base for Arnas's code in App: https://github.com/doda25-team11/app/tree/A3.3-Metrics

- Amy
I worked on trying to fix the problem of joining the Kubernetes clusters in A2 (in https://github.com/doda25-team11/operation/pull/13). Not all team members had this issue as the bug was only there for VirtualBox users. I reviewed https://github.com/doda25-team11/operation/pull/15 and started with A4 - Continuous experimentation (https://github.com/doda25-team11/operation/pull/16).

### Week Q1.6 (Dec 15+)
- Bill: https://github.com/doda25-team11/operation/pull/17 & https://github.com/doda25-team11/operation/pull/18
I updated readme to make it more clear for the next feedback round. I also added a service monitor for prometheus and make the metrics endpoint at /metrics.

- Figen: https://github.com/doda25-team11/operation/pull/19
I added the shadow launch as an additional use case and reviewed https://github.com/doda25-team11/operation/pull/18.

- Arnas: https://github.com/doda25-team11/operation/tree/rate-limiter
I was working on additional use case, that is traffic limiter as well as reviewing peers.

- Rodrigo: https://github.com/doda25-team11/operation/pull/15
Analysed all the feedback + reviewed features left for reaching highest points in rubric. Worked on making a troubleshooting md. Merged the traffic management content.

- Amy: https://github.com/doda25-team11/operation/pull/20
I worked on setting up the Grafana dashboards.

### Week Q1.7 (Jan 5+)
- Bill: https://github.com/doda25-team11/operation/pull/23
Added alertmanager, which can trigger alerts with /metrics.

- Rodrigo: https://github.com/doda25-team11/operation/pull/22
Worked on the deployment documentation markdown file + started thinking/planning on the presentation.

- Amy: https://github.com/doda25-team11/operation/pull/24
I worked on checking the rubrics and improving assignment 2.

- Figen: https://github.com/doda25-team11/lib-version/pull/2
I worked on checking the rubriks and improving assignment 1, here in particular I improved some hard-coding and overwriting, such that it  keeps a "single source of truth"
### Week Q1.8 (Jan 12+)
- Amy: https://github.com/doda25-team11/operation/pull/16
I worked on the presentation and the continous experimentation of assignment 4.
- Rodrigo: https://github.com/doda25-team11/operation/pull/25
Continued working on the deployment documentation file + created the images for it. Worked on the presentation
- Figen: https://github.com/doda25-team11/model-service/pull/8, https://github.com/doda25-team11/operation/pull/26
COntinued working on looking for ways to make sure A1 is consistent with the rubrik
- Arnas: added an ingress for Grafana https://github.com/doda25-team11/operation/commit/ae4bd640bbc310a2358a1eba4fec3db930fa7b80, where the dashboard can be accessed at endpoint /metrics. I checked the rubric for excelent in metrics.

### Week Q1.9 (Jan 19+)
- Amy: https://github.com/doda25-team11/operation/pull/28
I improved the traffic-management exercise (A4) by making sure we don't use hard-coded values.
- Bill: https://github.com/doda25-team11/operation/pull/27 
Added extension proposal.
- Rodrigo: https://github.com/doda25-team11/operation/pull/29
Reviewed #27, #28. Cleaned up files in helm, finished documentation
- Arnas https://github.com/doda25-team11/operation/pull/31. Improved Grafana, added shared folder for VMs.
- Figen: https://github.com/doda25-team11/operation/pull/30
Fixed the problems with shadow launch A4

### Week Q1.10 (Jan 26+)
- Bill: https://github.com/doda25-team11/operation/pull/33
I noticed that there was only one ssh key. There should be two. A2 - step 4. I fixed the SSH key looping issue that it supports 2+ keys and improved the playbook in such a way that you don't need to hard code ssh keys.
- Arnas: https://github.com/doda25-team11/operation/pull/34, https://github.com/doda25-team11/app/pull/5
I tried to change Prometheus to use custom its own instance instead of Istio, which the professor pointed out during the presentation, but encountered some issues with integration, which sadly I was unable to solve before the deadline.

### Example from Brightspace
- Alice: https://github.com/doda25-team1/lib-version/pull/1
I have worked on A1 and have contributed a versioning strategy for the library.
- Bob: https://github.com/doda25-team1/...
I have worked on A1 and [...]
