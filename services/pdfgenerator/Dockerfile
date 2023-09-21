FROM node:18-alpine AS build

# --- NETFREE CERT INTSALL ---
ADD https://netfree.link/dl/unix-ca.sh /home/netfree-unix-ca.sh 
RUN cat  /home/netfree-unix-ca.sh | sh
ENV NODE_EXTRA_CA_CERTS=/etc/ca-bundle.crt
ENV REQUESTS_CA_BUNDLE=/etc/ca-bundle.crt
ENV SSL_CERT_FILE=/etc/ca-bundle.crt
# --- END NETFREE CERT INTSALL ---

RUN apk --no-cache add build-base python3

WORKDIR /usr/app

COPY services/common services/common
COPY services/pdfgenerator/data services/pdfgenerator/data
COPY services/pdfgenerator/src services/pdfgenerator/src
COPY services/pdfgenerator/templates services/pdfgenerator/templates
COPY services/pdfgenerator/package.json services/pdfgenerator/.
COPY services/pdfgenerator/LICENSE services/pdfgenerator/.
COPY package.json .
COPY yarn.lock .
COPY .yarnrc.yml .
COPY .yarn .yarn

RUN corepack enable && \
    corepack prepare yarn@stable --activate

RUN yarn workspaces focus --production @microrealestate/pdfgenerator

FROM node:18-alpine
ENV NODE_ENV production
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV CHROMIUM_BIN "/usr/bin/chromium-browser"
RUN apk --no-cache add chromium
WORKDIR /usr/app
COPY --from=build /usr/app ./
CMD ["node", "services/pdfgenerator/src/index.js"]
