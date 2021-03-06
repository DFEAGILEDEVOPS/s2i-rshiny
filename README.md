
# R Shiny (RShiny) s2i image

[Source-to-Image s2i](https://docs.openshift.com/container-platform/3.6/architecture/core_concepts/builds_and_image_streams.html#source-build) is a framework that takes application source code as an input and produces a new image that runs the assembled application as output. Openshift builds can be triggered if either the code changes or the s2i builder image is updated. This means that we can have many apps in a project and we can apply a security update to them all by pushing an update to the builder image. A community of developers can focus on the code and use a shared builder image that focuses on security updates and shared best practices. This image also supports incremental compile which copies forward the packrat forward between runs so that the builder image doesn't have to build all the dependencies all the time.

First install the s2i tooling from https://github.com/openshift/source-to-image/releases

Build this builder: 

```
docker build -t dfeagiledevops/s2i-rshiny -f Dockerfile . 
```

Build a test hello world app with this builder (note the use of incremental build):

```
s2i build test/test-app/ dfeagiledevops/s2i-rshiny:latest sample-app --incremental
```

If you have changed your packrat dependencies you many need to run without incremental build. 

Build a real app with this builder (note the use of incremental build): 

```
 s2i build https://github.com/DFEAGILEDEVOPS/schools-workforce-benchmarking.git \
      dfeagiledevops/s2i-rshiny:latest schools-workforce-benchmarking --incremental
```

If you have changed your packrat dependencies you many need to run without incremental build. 

Run the real app: 

```
docker run -p 3838:3838 schools-workforce-benchmarking
```

Explore the real app:

```
http://localhost:3838
```

Note that this image supports incremental builds. If you do two builds with the same output name the second build should find the packrat/lib folder from the first build. This means that if you have only changed your R source code the second build should be a lot faster as it does not need to download all the dependencies. If you have changed your dependencies you may need to run without `--incremental` to force an update to the dependencies.  

Deploy your own R Shiny website onto Openshift V3 using this s2i image: 

```
oc new-app dfeagiledevops/s2i-rshiny~https://github.com/DFEAGILEDEVOPS/schools-workforce-benchmarking.git
```

That used to give a service and a route but if you just get a build config out of it you can add a service by looking at the command line tools hint on the console to get an `oc login xxxx` auth token then `oc project whatever` then `oc create -f - < service.json`. Alternatively you can open the `service.json` and paste it via the `Add to Project / Import YAML / JSON` on the web console. Finally expose the service with `oc expose svc/schools-workforce-benchmarking --hostname=www.example.com1`.
