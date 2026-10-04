/// Emergency phone numbers by country (tap-to-call on the help screen, and
/// in "call now" warnings).
library;

/// What a number is for; the help screen turns it into a label.
enum EmergencyService { all, ambulance, rescue1122, edhi, chhipa, police, fire, nhs111, poison, nurseLine, unified }

typedef EmergencyNumber = ({String number, EmergencyService service});

/// Numbers for [country], most important first; empty when we don't know them.
List<EmergencyNumber> emergencyNumbers(String country) {
  if (_eu112.contains(country)) return const [(number: '112', service: EmergencyService.all)];
  return _numbers[country] ?? const [];
}

/// The number to call in a "call now" warning, e.g. "1122 / 115"; null when
/// we don't know it (say "your local emergency number" instead).
String? primaryEmergencyNumber(String country) {
  if (country == 'PK') return '1122 / 115';
  return emergencyNumbers(country).firstOrNull?.number;
}

/// Countries where the hot-weather and load-shedding advice applies.
const heatAdviceCountries = {'PK', 'IN', 'BD'};

const _numbers = <String, List<EmergencyNumber>>{
  'PK': [
    (number: '1122', service: EmergencyService.rescue1122),
    (number: '115', service: EmergencyService.edhi),
    (number: '1020', service: EmergencyService.chhipa),
    (number: '15', service: EmergencyService.police),
    (number: '16', service: EmergencyService.fire),
  ],
  'GB': [
    (number: '999', service: EmergencyService.all),
    (number: '111', service: EmergencyService.nhs111),
  ],
  'US': [
    (number: '911', service: EmergencyService.all),
    (number: '1-800-222-1222', service: EmergencyService.poison),
  ],
  'CA': [
    (number: '911', service: EmergencyService.all),
    (number: '811', service: EmergencyService.nurseLine),
  ],
  'AE': [
    (number: '998', service: EmergencyService.ambulance),
    (number: '999', service: EmergencyService.police),
    (number: '997', service: EmergencyService.fire),
  ],
  'SA': [
    (number: '997', service: EmergencyService.ambulance),
    (number: '911', service: EmergencyService.unified),
    (number: '998', service: EmergencyService.fire),
    (number: '999', service: EmergencyService.police),
  ],
  'AU': [(number: '000', service: EmergencyService.all)],
  'NZ': [(number: '111', service: EmergencyService.all)],
  'IN': [(number: '112', service: EmergencyService.all), (number: '108', service: EmergencyService.ambulance)],
  'BD': [(number: '999', service: EmergencyService.all)],
  'QA': [(number: '999', service: EmergencyService.all)],
  'KW': [(number: '112', service: EmergencyService.all)],
  'OM': [(number: '9999', service: EmergencyService.all)],
  'BH': [(number: '999', service: EmergencyService.all)],
  'MY': [(number: '999', service: EmergencyService.all)],
  'TR': [(number: '112', service: EmergencyService.all)],
};

/// EU and EEA countries (and Switzerland), where 112 reaches every service.
const _eu112 = {
  'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', //
  'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'IS', 'LI', 'NO', 'CH',
};
