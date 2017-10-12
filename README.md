
# R Shiny (RShiny) s2i image

[Source-to-Image s2i](https://docs.openshift.com/container-platform/3.6/architecture/core_concepts/builds_and_image_streams.html#source-build) is a framework that takes application source code as an input and produces a new image that runs the assembled application as output. Openshift builds can be triggered if either the code changes or the s2i builder image is updated. This means that we can have many apps in a project and we can apply a security update to them all by pushing an update to the builder image. 

First install the s2i tooling from https://github.com/openshift/source-to-image/releases

Build this builder: 

```
docker build -t simonmassey/s2i-rshiny -f Dockerfile.centos7 . 
```

Build a test hello world app with this builder (note the use of incremental build):

```
s2i build test/test-app/ simonmassey/s2i-rshiny:latest sample-app --incremental
```

If you have changed your packrat dependencies you many need to run without incremental build. 

Build a real app with this builder (note the use of incremental build): 

```
 s2i build https://github.com/DFEAGILEDEVOPS/schools-workforce-benchmarking.git simonmassey/s2i-rshiny:latest schools-workforce-benchmarking
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

Note that this image supports incremental builds. If you do two builds with the same output name the second build should find the packrat/lib folder from the first build. This means that 

### TODO 

[_] create templates to use this on Openshift v3 Pro
