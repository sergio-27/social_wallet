import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/custodied_wallets_info_response.dart';
import 'package:social_wallet/models/db/user.dart';


part 'search_contact_state.dart';

class SearchContactCubit extends Cubit<SearchContactState> {

  WalletRepository walletRepository;

  SearchContactCubit({
    required this.walletRepository
  }) : super(SearchContactState());



  Future<void> getAppUser({
    String? userEmail
  }) async {
    emit(state.copyWith(status: SearchContactStatus.loading));
    if (userEmail == null || userEmail.isEmpty) {
      emit(
          state.copyWith(
            userList: [],
            status: SearchContactStatus.success,
          )
      );
    } else {
      try {
        User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
        List<User>? response = await getDbHelper().retrieveUsers();
        if (response.isNotEmpty && currUser != null) {
          List<User> filteredList = List.empty(growable: true);

          for (var element in response) {
            if (element.id != currUser.id) {
              String userName = element.username ?? "";
              if (element.userEmail.contains(userEmail) || userName.contains(userName)) {
                filteredList.add(element);
              }
            }
          }

          emit(
              state.copyWith(
                userList: filteredList,
                status: SearchContactStatus.success,
              )
          );
        }
      } catch (error) {
        emit(state.copyWith(status: SearchContactStatus.error));
      }
    }

  }
}
