###########
# BUILDER #
###########

# pull official base image
FROM python:3.11-slim-bullseye as builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN apt update && apt install -y gcc python3-dev musl-dev

COPY ./app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


##############
# FINAL STAGE#
##############

# pull official base image
FROM python:3.11-slim-bullseye

LABEL maintainer="Kwame Benqazy <iambenqazy@gmail.com>"

# create the app user
RUN useradd -m -s /bin/bash app

# create directory for the app user
RUN mkdir -p /app

# install dependencies
RUN apt update && apt-get install -y libpq-dev

COPY --chown=app:app --from=builder /usr/src/app/wheels /wheels
COPY --chown=app:app --from=builder /usr/src/app/requirements.txt .

RUN pip install --no-cache /wheels/*

# create the appropriate directories
ENV HOME=/app \
    DJANGO_STATIC_ROOT=/app/staticfiles/ \
    DJANGO_MEDIA_ROOT=/app/mediafiles/

# copy project & entrypoint.dev.sh
COPY --chown=app:app ./app/ $HOME
COPY --chown=app:app ./entrypoint.dev.sh /



RUN sed -i 's/\r$//g'  /entrypoint.dev.sh && chmod +x /entrypoint.dev.sh

# chown all the files to the app user
RUN chown -R app:app $HOME

# change to the app user
USER app

ENTRYPOINT ["/entrypoint.dev.sh"]
WORKDIR $HOME

CMD gunicorn app.wsgi:application --bind 0.0.0.0:8000