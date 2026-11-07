String dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

const _months = <String>[
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String niceDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';
