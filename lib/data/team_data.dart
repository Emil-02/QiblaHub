import '../models/team_member.dart';

abstract final class TeamData {
  static const titleKey = 'developmentTeamTitle';
  static const projectKey = 'teamProject';
  static const groupKey = 'teamGroup';
  static const lecturerLabelKey = 'teamLecturer';
  static const supervisedByKey = 'teamSupervisedBy';
  static const studentsLabelKey = 'teamStudents';
  static const studentCountKey = 'teamStudentCount';
  static const viewTeamKey = 'viewTeam';
  static const downloadLabelKey = 'downloadQiblaHubApk';
  static const downloadErrorKey = 'downloadOpenError';
  static const sourceLabelKey = 'sourceCode';
  static const sourceErrorKey = 'sourceCodeOpenError';

  static const lecturer = 'Dr. ALAMSYAH, S.Pd. I., M.H';

  static const members = <TeamMember>[
    TeamMember(name: 'Dwi Azzahra Sasqila Fitri', studentId: '105841118724'),
    TeamMember(name: 'Wuri Satya Natama', studentId: '105841118824'),
    TeamMember(name: 'Emil Rahmat', studentId: '105841119124'),
    TeamMember(name: 'Tyara Ayuliansyah', studentId: '105841119524'),
    TeamMember(name: 'Gefira Nur Fatima', studentId: '105841120124'),
    TeamMember(name: 'Muh Rafly Aprial Ridho', studentId: '105841112524'),
  ];

  static final downloadUri = Uri.parse(
    'https://github.com/Emil-02/QiblaHub/releases/latest',
  );

  static final sourceCodeUri = Uri.parse('https://github.com/Emil-02/QiblaHub');

  // APK release diunggah secara manual melalui halaman GitHub Releases.
}
