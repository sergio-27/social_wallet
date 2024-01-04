import 'package:bloc/bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/user.dart';
import 'package:social_wallet/models/db/user_contact.dart';


part 'user_contact_state.dart';

class UserContactCubit extends Cubit<UserContactState> {

  UserContactCubit() : super(UserContactState());

  Future<List<UserContact>?> getUserContactsBase(User currUser) async {
    return await getDbHelper().retrieveUserContact(currUser.id ?? 0);
  }

  Future<void> getUserContacts({int? excludedId}) async {
    emit(state.copyWith(status: UserContactStatus.loading));
    try {
      User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
      if (currUser != null) {
        List<UserContact>? response = await getUserContactsBase(currUser);

        if (response != null) {
          if (excludedId != null) {
            response = response.where((e) => e.id != excludedId && e.address != null).toList();
          } else {
            response = response.where((e) => e.address != null).toList();
          }
          emit(
              state.copyWith(
                userContactList: response,
                status: UserContactStatus.success,
              )
          );
        } else {
          emit(
              state.copyWith(
                userContactList: [],
                status: UserContactStatus.success,
              )
          );
        }
      } else {
        emit(
            state.copyWith(
              userContactList: [],
              status: UserContactStatus.success,
            )
        );
      }

    } catch (error) {
      emit(state.copyWith(status: UserContactStatus.error));
    }
  }
}
