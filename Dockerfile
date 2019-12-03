FROM scratch
COPY ./jx-app-fossa.sh /
RUN chmod +x /jx-app-fossa.sh
ENTRYPOINT ["/jx-app-fossa.sh"]
