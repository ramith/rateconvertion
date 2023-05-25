import ballerina/log;
import ballerinax/exchangerates;
import ramith/countryprofile;
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
@display {
    label: "rateconversion",
    id: "rateconversion-d330a15a-a71c-4419-99c0-dbda4393a63a"
}
service / on new http:Listener(9090) {
    @display {
        label: "Exchange Rates",
        id: "exchangerates-b76fcfe8-1e10-4460-bf2b-9e9fac9d2429"
    }
    exchangerates:Client exchangeratesEp;

    @display {
        label: "CountryProfile",
        id: "countryprofile-8076734e-ac1e-46f8-aac7-f656add04c8d"
    }
    countryprofile:Client countryprofileEp;

    function init() returns error? {
        self.exchangeratesEp = check new ();
        self.countryprofileEp = check new (config = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        });
    }

    resource function get convert(decimal amount = 1.0, string target = "AUD", string base = "USD") returns PricingInfo|error {

        log:printInfo("new request:", target = target, base = base, amount = amount);
        countryprofile:Currency getCurrencyCodeResponse = check self.countryprofileEp->getCurrencyCode(code = target);
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check self.exchangeratesEp->getExchangeRateFor(apikey = exchangeRateAPIKey, baseCurrency = base);

        decimal exchangeRate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        decimal convertedAmount = amount * exchangeRate;

        PricingInfo pricingInfo = {
            currencyCode: target,
            displayName: getCurrencyCodeResponse.displayName,
            amount: convertedAmount
        };

        return pricingInfo;
    }
}

type PricingInfo record {
    string currencyCode;
    string displayName;
    decimal amount;
};

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string exchangeRateAPIKey = ?;
