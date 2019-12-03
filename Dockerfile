FROM scratch
EXPOSE 8080
ENTRYPOINT ["/jx-app-fossa"]
COPY ./bin/ /