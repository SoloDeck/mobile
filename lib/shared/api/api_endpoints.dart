abstract final class ApiEndpoints {
  // Auth
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authMe = '/auth/me';
  static const authGoogle = '/auth/google';
  static const authForgotPassword = '/auth/password-reset/request';
  static const authResetPassword = '/auth/password-reset/confirm';

  // Users
  static const usersMe = '/users/me';

  // Clients
  static const clients = '/clients';
  static String clientById(String id) => '/clients/$id';
  static String clientCommunicationLogs(String id) => '/clients/$id/comm-logs';

  // Deals
  static const deals = '/deals';
  static String dealById(String id) => '/deals/$id';
  static String dealStage(String id) => '/deals/$id/stage';
  static String dealActivities(String id) => '/deals/$id/activity';

  // Projects
  static const projects = '/projects';
  static String projectById(String id) => '/projects/$id';

  // Tasks (polymorphic — entity_type: project | deal | reminder)
  static String projectTasks(String projectId) => '/projects/$projectId/tasks';
  static String dealTasks(String dealId) => '/deals/$dealId/tasks';
  static String reminderTasks(String reminderId) =>
      '/reminders/$reminderId/tasks';
  static String taskById(String id) => '/tasks/$id';
  static String taskChecklist(String taskId) => '/tasks/$taskId/checklist';
  static String checklistItem(String taskId, String itemId) =>
      '/tasks/$taskId/checklist/$itemId';

  // Proposals
  static const proposals = '/proposals';
  static String proposalById(String id) => '/proposals/$id';
  static String proposalSend(String id) => '/proposals/$id/send';
  static String proposalGenerate = '/proposals/generate';

  // Contracts
  static const contracts = '/contracts';
  static String contractById(String id) => '/contracts/$id';
  static String contractSign(String id) => '/contracts/$id/sign';

  // Invoices
  static const invoices = '/invoices';
  static String invoiceById(String id) => '/invoices/$id';
  static String invoicePayments(String id) => '/invoices/$id/payments';

  // Reminders
  static const reminders = '/reminders';
  static String reminderById(String id) => '/reminders/$id';

  // Analytics
  static const analyticsDashboard = '/analytics/dashboard';
  static const analyticsRevenue = '/analytics/revenue';
  static const analyticsPipeline = '/analytics/pipeline';
  static const analyticsWinRate = '/analytics/win-rate';
  static const analyticsTopClients = '/analytics/top-clients';

  // AI
  static const aiLeadsQualify = '/ai/leads/qualify';
}
