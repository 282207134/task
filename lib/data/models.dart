class Project {
  const Project(this.title, this.percent, this.color, {this.personal = false});
  final String title;
  final int percent, color;
  final bool personal;
}

const projects = [
  Project('Social Media App', 32, 0xFFDDB90E),
  Project('Meditation App', 55, 0xFFEC4A4B, personal: true),
  Project('Medical App', 40, 0xFFEF9899),
  Project('Sport App', 55, 0xFF4404AC, personal: true),
];

const categoryOptions = [
  'Design',
  'Social Media Design',
  'Research',
  'Dashboard Design',
  'Backend',
];
const memberNames = [
  'Quiche Hollandaise',
  'Alex Morgan',
  'Jamie Chen',
  'Taylor Reed',
  'Sam Wilson',
];
const defaultDescription =
    'Lorem ipsum dolor sit amet, consectetur tellus at '
    'rhoncus adipiscing elit. Vestibulum sagittis acium turpis in cursus. '
    'In hac habitasse platea dictumst.';
const defaultAgenda = [
  'Nullam ullamcorper hendrerit interdum.',
  'Fusce ut efficitur lorem integer.',
  'Etiam scelerisque suscipit tortor.',
  'Nam rhoncus eu eros a lacinia curabitur.',
  'Nam purus urna, posuere eget dictum in.',
];

class TaskCard {
  const TaskCard({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.category,
    required this.members,
  });
  final String id, title, description, category;
  final DateTime start, end;
  final List<String> members;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'category': category,
    'members': members,
  };

  factory TaskCard.fromJson(Map<String, dynamic> json) => TaskCard(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    category: json['category'] as String,
    members: List<String>.from(json['members'] as List),
  );
}

String shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
}
