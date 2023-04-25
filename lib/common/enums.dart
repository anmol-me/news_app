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
  validUrl('Please provide a valid url'),
  internalError('Internal error. Please try again.'),
  accessDenied('Access denied. Please check username or password.'),
  somethingWrongAdmin('Something went wrong. Please contact Administrator'),
  somethingWrongAuth('Something went wrong! Please login again'),
  requestTimeout('Connection Timeout. Could not connect to the server'),
  socket('Could not connect to the server.'),
  checkInternet('Please check internet connectivity'),
  catAlreadyExists('This category already exists.'),
  catNotDelete('Could not delete category.'),
  listEmpty('List is empty.'),
  generalError('An Error Occurred. Please retry.'),
  notOpenLink('Could not open link.');

  final String value;

  const ErrorString(this.value);
}

enum Message {
  categoryEmpty('No categories available.'),
  catCreated('Category successfully created.'),
  feedAdded('Subscription feed successfully added');

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
  imageNotFoundUrl('assets/notfound.png');

  final String value;

  const Constants(this.value);
}