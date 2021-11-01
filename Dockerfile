ARG IMAGE=store/intersystems/irishealth-community:2021.1.0.215.3
FROM $IMAGE AS I4HBuilder
LABEL maintainer="Renan Lourenco <renan.lourenco@intersystems.com>"

USER ${ISC_PACKAGE_MGRUSER}
ENV IRIS_PASSWORD="SYS"
ENV IRIS_INSTALLER="/tmp/Installer.cls"

COPY code/src /tmp/src
COPY scripts /tmp/scripts

USER root

RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /tmp/scripts \
    && chmod +x /tmp/scripts/build.sh

# Switch user back to IRIS owner and load initialization code and run
USER ${ISC_PACKAGE_MGRUSER}
SHELL ["/tmp/scripts/build.sh"]

# Install custom code
RUN \
  zn "HSLIB" \
  set sc = $SYSTEM.OBJ.Load("/tmp/src/Demo/Installer.cls","ck") \
  if sc do ##class(Demo.Installer).Install("/tmp/src/Demo")
SHELL ["/bin/bash", "-c"]

RUN echo "$IRIS_PASSWORD" >> /tmp/pwd.isc && /usr/irissys/dev/Container/changePassword.sh /tmp/pwd.isc

# 2nd stage to reduce size
FROM $IMAGE AS I4HDemo
LABEL maintainer "Renan Lourenço <renan.lourenco@intersystems.com>"
USER root
# replace in standard kit with what we modified in first stage
COPY --from=I4HBuilder /usr/irissys/iris.cpf /usr/irissys/.
COPY --from=I4HBuilder /usr/irissys/mgr/IRIS.DAT /usr/irissys/mgr/.
COPY --from=I4HBuilder /usr/irissys/mgr/hssys/IRIS.DAT /usr/irissys/mgr/hssys/.
COPY --from=I4HBuilder /usr/irissys/mgr/fhir/. /usr/irissys/mgr/fhir/.
COPY --from=I4HBuilder /usr/irissys/mgr/FHIRX0001R/. /usr/irissys/mgr/FHIRX0001R/.
COPY --from=I4HBuilder /usr/irissys/mgr/FHIRX0001V/. /usr/irissys/mgr/FHIRX0001V/.
# need to reset ownership for files copied
RUN \
  chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/iris.cpf \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/IRIS.DAT \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/fhir \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/FHIRX0001R \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/FHIRX0001V \
  && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/irissys/mgr/hssys/IRIS.DAT \
  && chmod -R 775 /usr/irissys/mgr/fhir/IRIS.DAT \
  && chmod -R 660 /usr/irissys/mgr/FHIRX0001R/IRIS.DAT \
  && chmod -R 660 /usr/irissys/mgr/FHIRX0001V/IRIS.DAT
