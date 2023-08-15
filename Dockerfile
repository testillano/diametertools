ARG base_tag=latest
FROM ghcr.io/testillano/diametertools_builder:${base_tag}
MAINTAINER testillano

LABEL testillano.diametertools.description="ert_diametertools library image"

WORKDIR /code/build

ARG make_procs=4
ARG build_type=Release

# ert_diametertools
COPY . /code/build/diametertools/
RUN set -x && \
    cd diametertools && cmake -DCMAKE_BUILD_TYPE=${build_type} . && make -j${make_procs} && make install && \
    cd .. && rm -rf diametertools && \
    set +x
