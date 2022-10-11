FROM python:3.10-slim-buster as base
ENV PYTHONUNBUFFERED 1
ENV PATH /code:/opt/venv/bin:$PATH
COPY requirements.txt ./
RUN set -ex; \
        python -m venv /opt/venv; \
        pip install --upgrade pip; \
        pip install -r requirements.txt;

# ============================================ Release

FROM python:3.10-slim-buster AS release

ENV PYTHONUNBUFFERED 1
ENV PATH /code:/opt/venv/bin:$PATH

WORKDIR /code
COPY --from=base /root/.cache /root/.cache
COPY --from=base /opt/venv /opt/venv

COPY relevance relevance/
COPY api api/

COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["gunicorn", "-w", "3", "--forwarded-allow-ips=\"*\"", "relevance.wsgi"]