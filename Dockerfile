ARG BASE_IMAGE=alpine

FROM $BASE_IMAGE as build
WORKDIR /build
RUN apk add python3 git nodejs yarn && \
    git clone https://github.com/Netflix/flamescope.git && \
    cd flamescope && yarn install && yarn run webpack

FROM $BASE_IMAGE as app
WORKDIR /app
RUN apk add python3 py3-pip libmagic
COPY --from=build /build/flamescope/app ./app
COPY --from=build /build/flamescope/run.py /build/flamescope/requirements.txt ./
RUN pip3 install -r requirements.txt && \
    mkdir /profiles && \
    sed -i -e s/127.0.0.1/0.0.0.0/g -e s~examples~/profiles~g app/config.py
EXPOSE 5000/tcp
ENTRYPOINT ["python3", "run.py"]
