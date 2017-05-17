"use strict";
const Docker = require('dockerode');
class DockerClient {
    constructor() {
        if (process.platform === 'win32') {
            this.endPoint = new Docker({ socketPath: "//./pipe/docker_engine" });
        }
        else {
            this.endPoint = new Docker({ socketPath: '/var/run/docker.sock' });
        }
    }
    getContainerDescriptors() {
        return new Promise((resolve, reject) => {
            this.endPoint.listContainers((err, containers) => {
                if (err) {
                    return reject(err);
                }
                return resolve(containers);
            });
        });
    }
    ;
    getImageDescriptors() {
        return new Promise((resolve, reject) => {
            this.endPoint.listImages((err, images) => {
                if (err) {
                    return reject(err);
                }
                return resolve(images);
            });
        });
    }
    ;
    getContainer(id) {
        return this.endPoint.getContainer(id);
    }
    getImage(id) {
        return this.endPoint.getImage(id);
    }
}
exports.docker = new DockerClient();
//# sourceMappingURL=docker-endpoint.js.map