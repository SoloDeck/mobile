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
  static String clientCommunicationLogs(String id) =>
      '/clients/$id/communication-logs';

  // Deals
  static const deals = '/deals';
  static String dealById(String id) => '/deals/$id';
  static String dealStageTransition(String id) => '/deals/$id/stage-transition';
  static String dealActivities(String id) => '/deals/$id/activities';

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
  static const analyticsRevenue = '/analytics/revenue';
  static const analyticsPipeline = '/analytics/pipeline';
  static const analyticsWinRate = '/analytics/win-rate';
  static const analyticsTopClients = '/analytics/top-clients';
}
