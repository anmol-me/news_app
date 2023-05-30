enum Mode { basic, advanced }

enum DropItems { none, refresh, ascending, descending, sort, read }

enum Sort {
  ascending('asc'),
  descending('desc');

  final String value;

  const Sort(this.value);
}

enum ErrorString {
  emptyField('Field cannot be empty'),
  username('Username field cannot be empty'),
  password('Password field cannot be empty'),
  validUrl('Please provide a valid url'),
  internalError('Internal error. Please try again'),
  accessDenied('Access denied. Please check username or password'),
  somethingWrongAdmin('Something went wrong. Please contact Administrator'),
  somethingWrongAuth('Something went wrong! Please login again'),
  requestTimeout('Connection Timeout. Could not connect to the server'),
  socket('Server error. Could not complete your request'),
  checkInternet('Please check internet connectivity'),
  catAlreadyExists('This category already exists'),
  catNotDelete('Could not delete category.'),
  listEmpty('List is empty'),
  demoDiscover('Cannot discover in demo mode'),
  demoAddCategory('Cannot add category in demo mode'),
  demoManageCategory('Limited support in demo mode'),
  demoEditCategory('Cannot edit category in demo mode'),
  demoDeleteCategory('Cannot delete category in demo mode'),
  demoRefreshSettings('Cannot refresh in demo mode'),
  demoSearch('Search disabled in demo mode'),
  demoDisabled('Feature disabled in demo mode'),
  generalError('An Error Occurred. Please retry'),
  notOpenLink('Could not open link'),
  limitedDemoWebSupport('Limited web support in demo mode');

  final String value;

  const ErrorString(this.value);
}

enum Message {
  categoryEmpty('No category feed available'),
  catCreated('Category successfully created'),
  feedAdded('Subscription feed successfully added'),
  feedEmpty('No feed available to manage');

  final String value;

  const Message(this.value);
}

enum Status {
  read('read'),
  unread('unread');

  final String value;

  const Status(this.value);
}

enum OrderBy {
  publishedAt('published_at'),
  status('status');

  final String value;

  const OrderBy(this.value);
}

enum Constants {
  imageNotFoundUrl('assets/images/notfound.png');

  final String value;

  const Constants(this.value);
}
