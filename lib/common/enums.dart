enum Mode { basic, advanced }

enum DropItems { none, refresh, ascending, descending, sort, read }

enum Sort {
  ascending('asc'),
  descending('desc');

  final String value;

  const Sort(this.value);
}

enum ErrorString {
  username('Username field cannot be empty'),
  password('Password field cannot be empty'),
  url('Please provide a valid url'),
  internalError('Internal error. Please try again.'),
  accessDenied('Access denied. Please check username or password.'),
  somethingWrongAdmin('Something went wrong. Please contact Administrator'),
  somethingWrongAuth('Something went wrong! Please login again'),
  requestTimeout('Request Timeout.'),
  socket('Could not connect to the server.'),
  image('https://www.iconsdb.com/icons/preview/gray/x-mark-5-xxl.png'),
  checkInternet('Please check Internet Connectivity'),
  timeout('Connection Timeout. Please retry.'),
  catAlreadyExists('This category already exists.'),
  catCreated('Category successfully created.'),
  catNotDelete('Could not delete category.'),
  // catCreated('Category successfully created.'),
  // catCreated('Category successfully created.'),
  // catCreated('Category successfully created.'),
  // catCreated('Category successfully created.')
  ;

  final String value;

  const ErrorString(this.value);
}

enum Message {
  categoryEmpty('No Categories available.'),
  o('unread');

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
