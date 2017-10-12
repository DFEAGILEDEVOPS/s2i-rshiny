
# RShiny s2i image

First install the s2i tooling from https://github.com/openshift/source-to-image/releases

Build this builder: 

```
docker build -t simonmassey/s2i-rshiny -f Dockerfile.centos7 . 
```

Build a test hello world app with this builder

```
s2i build test/test-app/ simonmassey/s2i-rshiny:latest sample-app
```

Build a real app with this builder: 

```
 s2i build https://github.com/DFEAGILEDEVOPS/schools-workforce-benchmarking.git simonmassey/s2i-rshiny:latest schools-workforce-benchmarking
```

Run the real app: 

```
docker run -p 3838:3838 schools-workforce-benchmarking
```

Explore the real app:


```
http://localhost:3838
```

### TODO 

[_] try save-artifacts to copy forward deps for incremental builds
[_] create templates to use this on Openshift v3 Pro
