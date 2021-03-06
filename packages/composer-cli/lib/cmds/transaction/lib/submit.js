/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const cmdUtil = require('../../utils/cmdutils');

/**
 * <p>
 * Composer deploy command
 * </p>
 * <p><a href="diagrams/Deploy.svg"><img src="diagrams/deploy.svg" style="width:100%;"/></a></p>
 * @private
 */
class Submit {

  /**
    * Command process for deploy command
    * @param {string} argv argument list from composer command
    * @return {Promise} promise when command complete
    */
    static handler(argv) {
        let businessNetworkConnection;
        let enrollId;
        let enrollSecret;
        let connectionProfileName = argv.connectionProfileName;
        let businessNetworkName;
        let cardName = argv.card;
        let usingCard = !(cardName===undefined);


        return (() => {
            if (!argv.enrollSecret && !usingCard) {
                return cmdUtil.prompt({
                    name: 'enrollmentSecret',
                    description: 'What is the enrollment secret of the user?',
                    required: true,
                    hidden: true,
                    replace: '*'
                })
                .then((result) => {
                    argv.enrollSecret = result.enrollmentSecret;
                });
            } else {
                return Promise.resolve();
            }
        })()
        .then(() => {
            enrollId = argv.enrollId;
            enrollSecret = argv.enrollSecret;
            businessNetworkName = argv.businessNetworkName;
            businessNetworkConnection = cmdUtil.createBusinessNetworkConnection();
            if (!usingCard){
                return businessNetworkConnection.connectWithDetails(connectionProfileName, businessNetworkName, enrollId, enrollSecret);
            } else {
                return businessNetworkConnection.connect(cardName);
            }
        })
        .then(() => {
            let data = argv.data;

            if (typeof data === 'string') {
                try {
                    data = JSON.parse(data);
                } catch(e) {
                    throw new Error('JSON error. Have you quoted the JSON string?', e);
                }
            } else {
                throw new Error('Data must be a string');
            }

            if (!data.$class) {
                throw new Error('$class attribute not supplied');
            }

            let businessNetwork = businessNetworkConnection.getBusinessNetwork();
            let serializer = businessNetwork.getSerializer();
            let resource = serializer.fromJSON(data);

            return businessNetworkConnection.submitTransaction(resource);
        })
        .then((submitted) => {
            console.log('Transaction Submitted.');
        });
    }

}

module.exports = Submit;
