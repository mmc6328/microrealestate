FROM node:18-alpine AS build

# --- NETFREE CERT INTSALL ---
ADD https://netfree.link/dl/unix-ca.sh /home/netfree-unix-ca.sh 
RUN cat  /home/netfree-unix-ca.sh | sh
ENV NODE_EXTRA_CA_CERTS=/etc/ca-bundle.crt
ENV REQUESTS_CA_BUNDLE=/etc/ca-bundle.crt
ENV SSL_CERT_FILE=/etc/ca-bundle.crt
# --- END NETFREE CERT INTSALL ---

ENV NEXT_TELEMETRY_DISABLED=1
# base path cannot be set at runtime: https://github.com/vercel/next.js/discussions/41769
ARG TENANT_BASE_PATH
ENV BASE_PATH=$TENANT_BASE_PATH
ENV NEXT_PUBLIC_BASE_PATH=$TENANT_BASE_PATH

RUN apk --no-cache add build-base python3

WORKDIR /usr/app

COPY package.json .
COPY yarn.lock .
COPY .yarnrc.yml .
COPY .yarn .yarn
COPY .eslintrc.json .
COPY webapps/commonui webapps/commonui
COPY webapps/tenant/public webapps/tenant/public
COPY webapps/tenant/locales webapps/tenant/locales
COPY webapps/tenant/src webapps/tenant/src
COPY webapps/tenant/.eslintrc.json webapps/tenant
COPY webapps/tenant/i18n.js webapps/tenant
COPY webapps/tenant/next.config.js webapps/tenant
COPY webapps/tenant/package.json webapps/tenant
COPY webapps/tenant/LICENSE webapps/tenant

RUN corepack enable && \
    corepack prepare yarn@stable --activate

RUN yarn workspaces focus @microrealestate/tenant 

FROM node:18-slim
ENV NEXT_TELEMETRY_DISABLED=1
# base path cannot be set at runtime: https://github.com/vercel/next.js/discussions/41769
ARG TENANT_BASE_PATH
ENV BASE_PATH=$TENANT_BASE_PATH
ENV NEXT_PUBLIC_BASE_PATH=$TENANT_BASE_PATH
COPY --from=build /usr/app ./
CMD yarn workspace @microrealestate/tenant run generateRuntimeEnvFile && \
    yarn workspace @microrealestate/tenant run dev -p $PORT
