ARG VERSION

FROM rabbitmq:$VERSION

RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_federation_management rabbitmq_stomp