# ECS and RDS Infrastructure

## Overview

```
                     ┌───────────────────────────┐                       
                     │      Github container     │                       
   push release img  │      registry             │                       
────────────────────►│                           │                       
                     │                           │                       
                     └────────────────┬──────────┘                       
            │                         │                                  
            │                         │                                  
         ALB│                         │                                  
            │                         │                                  
            │        ┌────────────────▼───────────┐                      
            │        │   ECS                      │                      
            │        │  ┌──────────────────────┐  │                      
            │        │  │  Target Group        │  │                      
            │        │  │                      │  │                      
            │        │  │   ┌──────────────┐   │  │     ┌───────────────┐
            │        │  │   │  Phoenix API │   │  │     │  Postgres RDS │
            │        │  │   │  (container) │   │  │     │               │
    GET     │        │  │   │              │   │  │     │               │
  ──────────┼────────│──┼───► /api         ◄───┼──│─────►               │
            │        │  │   │  /whcsites   │   │  │     │               │
            │        │  │   │   /:id       │   │  │     │               │
            │        │  │   │              │   │  │     │               │
            │        │  │   │ /healthz     │   │  │     │               │
            │        │  │   │              │   │  │     │               │
            │        │  │   └───────────▲──┘   │  │     └─────▲─────────┘
            │        │  │               │      │  │           │          
            │        │  └───────────────┼──────┘  │           │          
            │        │                  │         │           │          
            │        │                  │         │           │          
            │        └──────────────────┼─────────┘           │          
            │                           ▲                     │          
            │                           │                     │          
            │                 ┌─────────┼─────────────────────┼─┐        
                              │      Secrets Manager            │        
                              │       - secret key base         │        
                              │       - db password             │        
                              │                                 │        
                              └─────────────────────────────────┘        
```

The approach I have taken in the terraform code here is a mixture of two significant projects I have worked on in the past. One project had multiple services running on ECS and attempted to use CodeDeploy blue/green migrations. The other project had complex dns, load balancer, and networking components. I feel that I have successfully simplified and condensed those projects here.

### Why is BLANK the way that it is?

Most of my decisions were driven by errors and difficulty I experienced at previous positions. I am happy to discuss all of them.

One question I anticipate is: "why use ECS+Fargate?" and the answer is: "I didn't want to set up k8s or throw together a deployment system on ec2 instances." This decision is similar to deciding to walk through a mine field instead of buying a bus ticket to go around the long way, but I got there in the end.

### How to improve?

- The `.tf` files need some visual separaters to help with scanning the files.
- A `daemon` (batch) task should be used to migrate the db schema. If the process were well thought out and had safty rails to avoid incompatibilities, the daemon task could use ecto migrations from the api docker image.
- tf code should be broken up into tf modules to be reused in the Real Life situations where more services need to be deployed